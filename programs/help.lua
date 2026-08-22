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
