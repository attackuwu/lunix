-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Собирает упрощенную информацию о типе и размере объекта.
return function(context)
    local function statResolved(resolved, displayPath)
        if not context.exists(resolved) then
            return nil, context.errno.ENOENT
        end

        local directory = context.isDirectory(resolved)
        local size = 0
        if not directory then
            local handle, openError = io.open(resolved, "rb")
            if not handle then
                return nil, context.mapError(openError)
            end
            local content = handle:read("*a") or ""
            handle:close()
            size = #content
        end

        return {
            st_mode = directory and "directory" or "regular",
            st_size = size,
            st_nlink = 1,
            st_path = displayPath
        }
    end

    context.statResolved = statResolved

    return function(path)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end

        return statResolved(resolved, path)
    end
end
