-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Закрывает файловый дескриптор и удаляет его из таблицы открытых файлов.
return function(context)
    return function(fd)
        local descriptor = context.fds[fd]
        if not descriptor then
            return nil, context.errno.EBADF
        end

        local ok = true
        if descriptor.handle then
            ok = descriptor.handle:close()
        end
        context.fds[fd] = nil
        if not ok then
            return nil, context.errno.EIO
        end

        return 0
    end
end
