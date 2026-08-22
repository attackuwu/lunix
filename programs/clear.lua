-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Очищает терминал и снова показывает заголовок системы.
local desc = "Очистить экран"

local command = {
    name = "clear",
    desc = desc,
    run = function(shell)
        shell.clearScreen()
        print(shell.config.name .. " " .. shell.config.version)
        local kernelName = shell.config.kernelName or shell.config.nameKernel or "Lunix Kernel"
        print("Kernel: " .. kernelName)
    end
}

return command
