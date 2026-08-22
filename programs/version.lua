-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Показывает имя, версию Lunix и название условного ядра.
local desc = "Показать версию системы"

local command = {
    name = "version",
    desc = desc,
    run = function(shell)
        local kernelName = shell.config.kernelName or shell.config.nameKernel or "Lunix Kernel"
        print(shell.config.name .. " " .. shell.config.version)
        print("Kernel: " .. kernelName)
    end
}

return command
