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
