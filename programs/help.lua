-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Показывает все команды, которые shell загрузил из каталога programs.
local desc = "Показать список команд"

local command = {
    name = "help",
    desc = desc,
    run = function(shell)
        shell.printCommandList()
    end
}

return command
