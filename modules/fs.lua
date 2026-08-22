-- Находит каталог модулей, чтобы загружать syscall-файлы относительно fs.lua.
local source = debug.getinfo(1, "S").source
local scriptPath = source:sub(1, 1) == "@" and source:sub(2) or source
local modulesDir = scriptPath:match("^(.*)[/\\\\]") or "."
local syscallsDir = modulesDir .. "/syscalls"

-- Безопасно заключает путь в кавычки для вызова внешней команды.
local function quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Загружает один syscall-модуль и возвращает его фабрику.
local function loadModule(name)
    local loader, err = loadfile(syscallsDir .. "/" .. name .. ".lua")
    if not loader then
        error("Ошибка загрузки syscall " .. name .. ": " .. tostring(err))
    end

    local ok, module = pcall(loader)
    if not ok then
        error("Ошибка инициализации syscall " .. name .. ": " .. tostring(module))
    end

    return module
end

local errno = loadModule("errno")
local constants = loadModule("constants")

-- Создает файловую систему с виртуальным корнем, текущим каталогом и дескрипторами.
local function createFileSystem(root)
    root = root:gsub("[/\\\\]+$", "")

    local context = {
        root = root,
        cwd = "/",
        fds = {},
        dirs = {},
        nextFd = 3,
        nextDir = 1,
        errno = errno,
        constants = constants,
        syscalls = {},
        quote = quote
    }

    function context.commandSucceeded(status)
        return status == true or status == 0
    end

    -- Преобразует виртуальный путь в путь внутри физического каталога root.
    function context.resolve(path)
        if type(path) ~= "string" or path == "" or path:find("%z") then
            return nil, errno.EINVAL
        end

        local combined = path:sub(1, 1) == "/" and path or context.cwd .. "/" .. path
        local parts = {}
        for part in combined:gmatch("[^/]+") do
            if part == ".." then
                if #parts > 0 then
                    table.remove(parts)
                end
            elseif part ~= "." then
                table.insert(parts, part)
            end
        end

        local virtual = "/" .. table.concat(parts, "/")
        local host = root .. (virtual == "/" and "" or virtual)
        return host
    end

    -- Преобразует физический путь обратно в путь виртуальной файловой системы.
    function context.virtualPath(path)
        local suffix = path:sub(#root + 1)
        return suffix == "" and "/" or suffix
    end

    -- Проверяет существование объекта в host-файловой системе.
    function context.exists(path)
        local status = os.execute("test -e " .. quote(path) .. " >/dev/null 2>&1")
        return context.commandSucceeded(status)
    end

    -- Проверяет, является ли объект каталогом.
    function context.isDirectory(path)
        local status = os.execute("test -d " .. quote(path) .. " >/dev/null 2>&1")
        return context.commandSucceeded(status)
    end

    -- Проверяет наличие родительского каталога перед созданием объекта.
    function context.parentExists(path)
        local parent = path:match("^(.*)/[^/]+$")
        return parent ~= nil and context.isDirectory(parent)
    end

    -- Проверяет, можно ли удалить каталог как пустой.
    function context.directoryEmpty(path)
        local handle = io.popen("ls -a1 " .. quote(path) .. " 2>/dev/null")
        if not handle then
            return false
        end

        for name in handle:lines() do
            if name ~= "." and name ~= ".." then
                handle:close()
                return false
            end
        end
        handle:close()
        return true
    end

    -- Проверяет право чтения, записи или выполнения через host-команду test.
    function context.testAccess(test, path)
        local status = os.execute("test " .. test .. " " .. quote(path) .. " >/dev/null 2>&1")
        return context.commandSucceeded(status)
    end

    -- Переводит текст ошибки host-операции в код errno Lunix.
    function context.mapError(message)
        local text = string.lower(tostring(message or ""))
        if text:find("no such") or text:find("not found") or text:find("does not exist") then
            return errno.ENOENT
        elseif text:find("permission denied") then
            return errno.EACCES
        elseif text:find("is a directory") then
            return errno.EISDIR
        elseif text:find("not a directory") then
            return errno.ENOTDIR
        elseif text:find("file exists") then
            return errno.EEXIST
        elseif text:find("invalid argument") then
            return errno.EINVAL
        elseif text:find("illegal seek") then
            return errno.ESPIPE
        elseif text:find("no space") then
            return errno.ENOSPC
        end
        return errno.EIO
    end

    -- Эти операции будут доступны через общий context и публичный объект filesystem.
    local syscallNames = {
        "open", "close", "read", "write", "lseek",
        "stat", "fstat", "unlink", "rename", "mkdir", "rmdir",
        "chdir", "getcwd", "access", "opendir", "readdir", "closedir"
    }

    -- Создает реализации syscall после загрузки всех их фабрик.
    for _, name in ipairs(syscallNames) do
        context.syscalls[name] = loadModule(name)(context)
    end

    local filesystem = {
        root = root,
        constants = constants,
        errno = errno,
        syscalls = context.syscalls
    }

    for _, name in ipairs(syscallNames) do
        filesystem[name] = context.syscalls[name]
    end

    -- Создает физический каталог, который используется как корень системы.
    function filesystem.ensure()
        local status = os.execute("mkdir -p " .. quote(root) .. " 2>/dev/null")
        return context.commandSucceeded(status)
    end

    -- Возвращает host-путь для отладки или внутренних проверок.
    function filesystem.path(path)
        return context.resolve(path)
    end

    -- Читает имена объектов из виртуального корневого каталога.
    function filesystem.list()
        local directory, openError = filesystem.opendir("/")
        if not directory then
            return nil, openError
        end

        local files = {}
        while true do
            local name, readError = filesystem.readdir(directory)
            if not name then
                filesystem.closedir(directory)
                if readError then
                    return nil, readError
                end
                break
            end
            table.insert(files, name)
        end

        return files
    end

    -- Создает файл, открывая его с флагом O_CREAT и сразу закрывая.
    function filesystem.touch(path)
        local fd, openError = filesystem.open(path, { constants.O_CREAT, constants.O_WRONLY }, 438)
        if not fd then
            return nil, openError
        end
        return filesystem.close(fd)
    end

    -- Читает весь файл блоками и закрывает открытый дескриптор.
    function filesystem.readFile(path)
        local fd, openError = filesystem.open(path, { constants.O_RDONLY })
        if not fd then
            return nil, openError
        end

        local chunks = {}
        while true do
            local data, readError = filesystem.read(fd, 8192)
            if not data then
                filesystem.close(fd)
                return nil, readError
            end
            if data == "" then
                break
            end
            table.insert(chunks, data)
        end

        local closeResult, closeError = filesystem.close(fd)
        if not closeResult then
            return nil, closeError
        end

        return table.concat(chunks)
    end

    -- Предоставляет более понятное имя для удаления обычного файла.
    function filesystem.remove(path)
        return filesystem.unlink(path)
    end

    filesystem.ensure()
    return filesystem
end

return {
    new = createFileSystem
}
