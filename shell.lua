-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Загружает модуль виртуальной файловой системы и создает ее корень в luafs.
local function loadFileSystem(baseDir)
    local loader, err = loadfile(baseDir .. "/modules/fs.lua")
    if not loader then
        error("Ошибка загрузки модуля fs.lua: " .. tostring(err))
    end

    local module = loader()
    return module.new(baseDir .. "/luafs")
end

-- Разбивает введенную строку на имя команды и аргументы по пробелам.
local function splitInput(input)
    local args = {}
    for argument in input:gmatch("%S+") do
        table.insert(args, argument)
    end
    return args
end

-- Экранирует путь перед передачей его внешней shell-команде.
local function quoteShellArgument(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Находит Lua-файлы программ и регистрирует возвращенные ими команды.
local function loadCommands(programsDir)
    local commands = {}
    local files = {}

    local handle = io.popen("ls -1 " .. quoteShellArgument(programsDir) .. " 2>/dev/null")
    if handle then
        for file in handle:lines() do
            if file:match("%.lua$") then
                table.insert(files, file)
            end
        end
        handle:close()
    end

    for _, file in ipairs(files) do
        local path = programsDir .. "/" .. file
        local chunk, err = loadfile(path)

        if not chunk then
            print("Ошибка загрузки команды " .. file .. ": " .. err)
        else
            local ok, command = pcall(chunk)
            if ok and type(command) == "table" and command.name then
                commands[command.name] = command
            else
                print("Файл " .. file .. " не вернул таблицу команды.")
            end
        end
    end

    return commands
end

-- Создает общий объект shell и функцию, запускающую интерактивный цикл.
local function createShell(config, baseDir)
    local programsDir = baseDir .. "/programs"
    local commands = loadCommands(programsDir)
    local filesystem = loadFileSystem(baseDir)
    local shouldExit = false

    local shell = {
        config = config,
        commands = commands,
        fs = filesystem,
        -- Показывает название системы и ядра при запуске оболочки.
        printWelcome = function()
            local kernelName = config.kernelName or config.nameKernel or "Lunix Kernel"
            print(config.name .. " " .. config.version)
            print("Kernel: " .. kernelName)
        end,
        -- Выводит команды, найденные в каталоге programs, в алфавитном порядке.
        printCommandList = function()
            print("Список команд:")

            local names = {}
            for name in pairs(commands) do
                table.insert(names, name)
            end
            table.sort(names)

            for _, name in ipairs(names) do
                local desc = commands[name].desc or "Без описания"
                print(string.format("%-8s - %s", name, desc))
            end
        end,
        -- Очищает экран средствами host-системы.
        clearScreen = function()
            if not os.execute("clear") then
                os.execute("cls")
            end
        end,
        -- Просит главный цикл завершить работу после текущей команды.
        shutdown = function()
            shouldExit = true
        end
    }

        return shell, function()
            -- При запуске из Meson подключается настоящий терминал, если он доступен.
            local terminalInput
            local terminalOutput

            if os.getenv("LUNIX_TTY") == "1" then
                terminalInput = io.open("/dev/tty", "r")
                terminalOutput = io.open("/dev/tty", "w")
            end

        if terminalInput then
            io.input(terminalInput)
        end
        if terminalOutput then
            io.output(terminalOutput)
        end

        shell.printWelcome()

        -- Главный цикл: приглашение, чтение команды, поиск и запуск программы.
        while true do
            io.write(config.shellPrompt)
            io.flush()

            local input = io.read()
            if input == nil then
                break
            end

            input = input:gsub("^%s+", ""):gsub("%s+$", "")
            if input ~= "" then
                local args = splitInput(input)
                local commandName = table.remove(args, 1)
                local command = commands[commandName]

                if command then
                    local ok, commandError = pcall(command.run, shell, args)
                    if not ok then
                        print("Ошибка выполнения команды: " .. tostring(commandError))
                    end
                else
                    print("Неизвестная команда: " .. commandName)
                end
            end

            if shouldExit then
                break
            end
        end
    end
end

return function(config, baseDir)
    local shell, run = createShell(config, baseDir)
    run()
end
