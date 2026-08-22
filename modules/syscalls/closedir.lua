-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Закрывает дескриптор каталога, открытый через opendir.
return function(context)
    return function(directory)
        local descriptor = context.dirs[directory]
        if not descriptor then
            return nil, context.errno.EBADF
        end

        local ok = descriptor.handle:close()
        context.dirs[directory] = nil
        if not ok then
            return nil, context.errno.EIO
        end

        return 0
    end
end
