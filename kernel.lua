-- Ядро Lunix хранит глобальные настройки системы
local config = {
    name = "Lunix (Lua Unix)",
    kernelName = "LKNU-lts (Lua Kernel is Not Unix)",
    nameKernel = "LKNU-lts (Lua Kernel is Not Unix)",
    version = "Alpha 0.01 Build 2208",
    shellPrompt = "lunix > "
}

-- Определяет каталог проекта относительно расположения запущенного kernel.lua.
local source = debug.getinfo(1, "S").source
local scriptPath = source:sub(1, 1) == "@" and source:sub(2) or source
local baseDir = scriptPath:match("^(.*)[/\\\\]") or "."

-- Ядро загружает оболочку и передает ей конфигурацию и каталог проекта.
local shellLoader = assert(loadfile(baseDir .. "/shell.lua"))
local shellRunner = shellLoader()
shellRunner(config, baseDir)
