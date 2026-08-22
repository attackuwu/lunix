-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Удаляет существующий пустой каталог.
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
        if not context.directoryEmpty(resolved) then
            return nil, context.errno.ENOTEMPTY
        end

        local removed, removeError = os.remove(resolved)
        if not removed then
            return nil, context.mapError(removeError)
        end

        return 0
    end
end
