-- Переименовывает или перемещает объект между виртуальными путями.
return function(context)
    return function(oldPath, newPath)
        local oldResolved, oldError = context.resolve(oldPath)
        if not oldResolved then
            return nil, oldError
        end

        local newResolved, newError = context.resolve(newPath)
        if not newResolved then
            return nil, newError
        end
        if not context.exists(oldResolved) then
            return nil, context.errno.ENOENT
        end
        if not context.parentExists(newResolved) then
            return nil, context.errno.ENOENT
        end

        local renamed, renameError = os.rename(oldResolved, newResolved)
        if not renamed then
            return nil, context.mapError(renameError)
        end

        return 0
    end
end
