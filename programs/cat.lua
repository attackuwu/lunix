-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Показывает содержимое одного файла виртуальной файловой системы.
local desc = "Показать содержимое файла из папки luafs"

local command = {
    name = "cat",
    desc = desc,
    run = function(shell, args)
        local name = args[1]
        if not name or args[2] then
            print("Использование: cat <имя-файла>")
            return
        end

        local content, err = shell.fs.readFile(name)
        if not content then
            print("Ошибка: " .. err)
            return
        end

        io.write(content)
        if content == "" or content:sub(-1) ~= "\n" then
            io.write("\n")
        end
    end
}

return command
