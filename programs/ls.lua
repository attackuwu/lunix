-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Показывает имена объектов в корневом каталоге виртуальной ФС.
local desc = "Показать файлы в папке luafs"

local command = {
    name = "ls",
    desc = desc,
    run = function(shell)
        local files, err = shell.fs.list()
        if not files then
            print("Ошибка: " .. err)
            return
        end

        if #files == 0 then
            print("Папка luafs пуста")
            return
        end

        for _, name in ipairs(files) do
            print(name)
        end
    end
}

return command
