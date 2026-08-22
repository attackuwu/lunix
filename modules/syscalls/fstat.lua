-- Возвращает информацию о файле по уже открытому файловому дескриптору.
return function(context)
    return function(fd)
        local descriptor = context.fds[fd]
        if not descriptor then
            return nil, context.errno.EBADF
        end
        return context.statResolved(descriptor.path, descriptor.virtualPath)
    end
end
