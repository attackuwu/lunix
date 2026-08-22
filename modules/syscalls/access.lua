-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Проверяет существование объекта и доступ к нему по флагам F_OK/R_OK/W_OK/X_OK.
return function(context)
    local constants = context.constants

    local function hasMode(mode, name)
        if mode == nil or mode == constants.F_OK then
            return false
        end
        if type(mode) == "string" then
            return mode == name
        end
        if type(mode) == "table" then
            for _, value in ipairs(mode) do
                if value == name then
                    return true
                end
            end
        end
        return false
    end

    return function(path, mode)
        local resolved, resolveError = context.resolve(path)
        if not resolved then
            return nil, resolveError
        end

        local readable = hasMode(mode, constants.R_OK)
        local writable = hasMode(mode, constants.W_OK)
        local executable = hasMode(mode, constants.X_OK)
        local knownMode = mode == nil or mode == constants.F_OK
            or readable or writable or executable
        if type(mode) == "table" then
            for _, value in ipairs(mode) do
                if value ~= constants.F_OK and value ~= constants.R_OK
                    and value ~= constants.W_OK and value ~= constants.X_OK then
                    knownMode = false
                end
            end
        elseif mode ~= nil and mode ~= constants.F_OK
            and mode ~= constants.R_OK and mode ~= constants.W_OK and mode ~= constants.X_OK then
            knownMode = false
        end

        if not knownMode then
            return nil, context.errno.EINVAL
        end
        if not context.exists(resolved) then
            return nil, context.errno.ENOENT
        end
        if mode == nil or mode == constants.F_OK then
            return 0
        end
        if readable and not context.testAccess("-r", resolved) then
            return nil, context.errno.EACCES
        end
        if writable and not context.testAccess("-w", resolved) then
            return nil, context.errno.EACCES
        end
        if executable and not context.testAccess("-x", resolved) then
            return nil, context.errno.EACCES
        end

        return 0
    end
end
