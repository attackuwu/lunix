-- Создает пустой файл в виртуальной файловой системе.
local desc = "Создать пустой файл в папке luafs"

local command = {
    name = "touch",
    desc = desc,
    run = function(shell, args)
        local name = args[1]
        if not name or args[2] then
            print("Использование: touch <имя-файла>")
            return
        end

        local ok, err = shell.fs.touch(name)
        if not ok then
            print("Ошибка: " .. err)
            return
        end

        print("Создан файл: " .. name)
    end
}

return command
