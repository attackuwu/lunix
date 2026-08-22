-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Читает заданное количество байтов из открытого файла.
return function(context)
    return function(fd, count)
        local descriptor = context.fds[fd]
        if not descriptor then
            return nil, context.errno.EBADF
        end
        if not descriptor.readable then
            return nil, context.errno.EBADF
        end
        if descriptor.directory then
            return nil, context.errno.EISDIR
        end
        if type(count) ~= "number" or count < 0 or count % 1 ~= 0 then
            return nil, context.errno.EINVAL
        end

        local data, readError = descriptor.handle:read(count)
        if data == nil and readError then
            return nil, context.mapError(readError)
        end

        return data or ""
    end
end
