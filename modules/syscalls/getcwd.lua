-- Copyright (c) 2026 attackuwu (https://github.com/attackuwu). All Rights Reserved.
-- SPDX-License-Identifier: APSL-2.0

-- Возвращает текущий виртуальный рабочий каталог.
return function(context)
    return function()
        return context.cwd
    end
end
