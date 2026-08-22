-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Возвращает следующее имя из открытого каталога.
return function(context)
    return function(directory)
        local descriptor = context.dirs[directory]
        if not descriptor then
            return nil, context.errno.EBADF
        end

        while true do
            local name = descriptor.handle:read("*l")
            if not name then
                return nil
            end
            if name ~= "." and name ~= ".." then
                return name
            end
        end
    end
end
