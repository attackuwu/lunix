-- Возвращает текущий виртуальный рабочий каталог.
return function(context)
    return function()
        return context.cwd
    end
end
