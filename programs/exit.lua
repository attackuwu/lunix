-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Просит главный цикл shell завершить работу.
local desc = "Выйти из оболочки"

local command = {
    name = "exit",
    desc = desc,
    run = function(shell)
        shell.shutdown()
    end
}

return command
