-- Создает один новый каталог внутри виртуальной файловой системы.
return function(context)
    return function(path, mode)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end
        if context.exists(resolved) then
            return nil, context.errno.EEXIST
        end
        if not context.parentExists(resolved) then
            return nil, context.errno.ENOENT
        end

        local created = os.execute("mkdir " .. context.quote(resolved) .. " 2>/dev/null")
        if not context.commandSucceeded(created) then
            return nil, context.errno.EIO
        end

        return 0
    end
end
