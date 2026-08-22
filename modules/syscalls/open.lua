-- Открывает или создает файл и выдает ему внутренний файловый дескриптор.
return function(context)
    local constants = context.constants

    local function hasFlag(flags, name)
        if type(flags) == "string" then
            return flags == name
        end

        if type(flags) == "table" then
            for _, flag in ipairs(flags) do
                if flag == name then
                    return true
                end
            end
        end

        return false
    end

    return function(path, flags, mode)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end

        flags = flags or { constants.O_RDONLY }
        local readable = not hasFlag(flags, constants.O_WRONLY)
        local writable = hasFlag(flags, constants.O_WRONLY) or hasFlag(flags, constants.O_RDWR)
        local create = hasFlag(flags, constants.O_CREAT)
        local exclusive = hasFlag(flags, constants.O_EXCL)
        local truncate = hasFlag(flags, constants.O_TRUNC)
        local append = hasFlag(flags, constants.O_APPEND)
        local exists = context.exists(resolved)

        if exists and create and exclusive then
            return nil, context.errno.EEXIST
        end
        if not exists and not create then
            return nil, context.errno.ENOENT
        end
        local directory = context.isDirectory(resolved)
        if directory and writable then
            return nil, context.errno.EISDIR
        end

        if directory then
            local fd = context.nextFd
            context.nextFd = context.nextFd + 1
            context.fds[fd] = {
                path = resolved,
                virtualPath = path,
                readable = true,
                writable = false,
                directory = true
            }
            return fd
        end

        if not exists then
            local created, createError = io.open(resolved, "w")
            if not created then
                return nil, context.mapError(createError)
            end
            created:close()
        end

        local ioMode
        if append then
            ioMode = readable and "a+" or "a"
        elseif truncate then
            ioMode = writable and (readable and "w+" or "w") or nil
        elseif readable and writable then
            ioMode = "r+"
        elseif writable then
            ioMode = "r+"
        else
            ioMode = "r"
        end

        if not ioMode then
            return nil, context.errno.EINVAL
        end

        local handle, openError = io.open(resolved, ioMode)
        if not handle then
            return nil, context.mapError(openError)
        end

        if append then
            handle:seek("end")
        end

        local fd = context.nextFd
        context.nextFd = context.nextFd + 1
        context.fds[fd] = {
            handle = handle,
            path = resolved,
            virtualPath = path,
            readable = readable,
            writable = writable,
            directory = false
        }

        return fd
    end
end
