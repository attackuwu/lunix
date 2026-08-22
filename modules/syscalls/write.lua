-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Записывает строку в открытый файл и возвращает число записанных байтов.
return function(context)
    return function(fd, data)
        local descriptor = context.fds[fd]
        if not descriptor then
            return nil, context.errno.EBADF
        end
        if not descriptor.writable then
            return nil, context.errno.EBADF
        end
        if descriptor.directory then
            return nil, context.errno.EISDIR
        end
        if type(data) ~= "string" then
            return nil, context.errno.EINVAL
        end

        local ok, writeError = descriptor.handle:write(data)
        if not ok then
            return nil, context.mapError(writeError)
        end
        descriptor.handle:flush()

        return #data
    end
end
