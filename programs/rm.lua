-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Удаляет один обычный файл из виртуальной файловой системы.
local desc = "Удалить файл из папки luafs"

local command = {
    name = "rm",
    desc = desc,
    run = function(shell, args)
        local name = args[1]
        if not name or args[2] then
            print("Использование: rm <имя-файла>")
            return
        end

        local ok, err = shell.fs.remove(name)
        if not ok then
            print("Ошибка: " .. err)
            return
        end

        print("Удалён файл: " .. name)
    end
}

return command
