-- Меняет текущий каталог только внутри виртуальной файловой системы.
return function(context)
    return function(path)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end
        if not context.exists(resolved) then
            return nil, context.errno.ENOENT
        end
        if not context.isDirectory(resolved) then
            return nil, context.errno.ENOTDIR
        end

        context.cwd = context.virtualPath(resolved)
        return 0
    end
end
