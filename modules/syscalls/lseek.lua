-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Перемещает позицию чтения и записи внутри открытого файла.
return function(context)
    return function(fd, offset, whence)
        local descriptor = context.fds[fd]
        if not descriptor then
            return nil, context.errno.EBADF
        end
        if descriptor.directory then
            return nil, context.errno.ESPIPE
        end
        if type(offset) ~= "number" or offset % 1 ~= 0 then
            return nil, context.errno.EINVAL
        end

        local position, seekError
        if whence == context.constants.SEEK_SET then
            position, seekError = descriptor.handle:seek("set", offset)
        elseif whence == context.constants.SEEK_CUR then
            position, seekError = descriptor.handle:seek("cur", offset)
        elseif whence == context.constants.SEEK_END then
            position, seekError = descriptor.handle:seek("end", offset)
        else
            return nil, context.errno.EINVAL
        end

        if not position then
            return nil, context.mapError(seekError)
        end

        return position
    end
end
