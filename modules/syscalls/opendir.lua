-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Открывает каталог для последовательного чтения его имен.
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

        local handle = io.popen("ls -a1 " .. context.quote(resolved) .. " 2>/dev/null")
        if not handle then
            return nil, context.errno.EIO
        end

        local directory = context.nextDir
        context.nextDir = context.nextDir + 1
        context.dirs[directory] = {
            handle = handle,
            path = resolved
        }

        return directory
    end
end
