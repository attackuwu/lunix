-- Удаляет обычный файл, но не каталог.
return function(context)
    return function(path)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end
        if not context.exists(resolved) then
            return nil, context.errno.ENOENT
        end
        if context.isDirectory(resolved) then
            return nil, context.errno.EISDIR
        end

        local removed, removeError = os.remove(resolved)
        if not removed then
            return nil, context.mapError(removeError)
        end

        return 0
    end
end
