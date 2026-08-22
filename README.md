<div align="center">

# `lunix > _`

**Lua Unix playground for people who like terminals a little too much.**

[![Lua](https://img.shields.io/badge/Lua-5.3%20%7C%205.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Meson](https://img.shields.io/badge/build-Meson-00A877?style=for-the-badge)](https://mesonbuild.com/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Unix-FCC624?style=for-the-badge&logo=linux&logoColor=black)](#требования)
[![Status](https://img.shields.io/badge/status-Alpha-E95420?style=for-the-badge)](#статус-проекта)
[![License](https://img.shields.io/badge/license-APSL--2.0-6E5494?style=for-the-badge)](LICENSE)

</div>

```text
    _                    _
   | |_   _ _ __   __  _(_)_  __
   | | | | | '_ \ / / | | \ \/ /
   | | |_| | | | / /__| | |>  <
   |_|\__,_|_| |_\____/_|_/_/\_\

   Lua Unix // Alpha 0.01 // build 2208
```

> A tiny Unix-like playground powered by Lua, shell commands and questionable amounts of enthusiasm.

**Lunix (Lua Unix)** — небольшой фанатский экспериментальный проект на Lua. Это не настоящая операционная система, а Unix-подобная среда с интерактивной оболочкой, виртуальным корнем файловой системы и набором syscall-подобных операций.

Проект создан ради экспериментов с Lua, shell-командами и базовыми идеями Unix. Сейчас Lunix находится на ранней стадии **Alpha** и является скорее демонстрационной "свистелкой", чем полноценной ОС.

```bash
meson setup build && meson compile -C build run
```

<details>
<summary><strong>Что происходит после запуска?</strong></summary>

Lunix поднимает оболочку, подключает каталог `luafs/` как виртуальный корень и автоматически загружает Lua-команды из `programs/`. Файловые операции остаются внутри этого каталога, а Unix-команды host-системы используются как низкоуровневый механизм.

</details>

<br>

## Возможности

- интерактивная shell-оболочка;
- виртуальный корень файловой системы в каталоге `luafs/`;
- автоматическая загрузка команд из каталога `programs/`;
- syscall-подобный API для работы с файлами и каталогами;
- виртуальный текущий рабочий каталог;
- Unix-подобные флаги открытия файлов и коды ошибок `errno`;
- запуск через Meson.

Физические операции выполняются внутри каталога `luafs/`. Пути вроде `/notes.txt` относятся к виртуальной файловой системе Lunix и не указывают напрямую на произвольные места в host-системе.

## Статус проекта

Текущая версия, отображаемая оболочкой:

```text
Lunix (Lua Unix) Alpha 0.01 Build 2208
Kernel: LKNU-lts (Lua Kernel is Not Unix)
```

Проект находится в разработке. API, список команд и внутренняя реализация могут изменяться.

## Требования

- Linux рекомендуется как основная платформа;
- Unix-подобная система с доступными командами `ls`, `test`, `mkdir`, `clear` и стандартными файловыми операциями;
- macOS также может подойти благодаря Unix-окружению;
- Lua 5.3 или Lua 5.4;
- Meson версии 0.56 или новее.

Windows без Unix-совместимого окружения официально не поддерживается, поскольку файловая система и часть оболочки используют Unix-команды host-системы.

## Установка и запуск

Клонируйте репозиторий и перейдите в его каталог:

```bash
git clone <URL-репозитория>
cd Lunix
```

Создайте каталог сборки Meson:

```bash
meson setup build
```

Запустите Lunix:

```bash
meson compile -C build run
```

После запуска появится приглашение оболочки:

```text
lunix >
```

Для завершения работы выполните:

```text
exit
```

## Пример работы

```text
$ meson compile -C build run
Lunix (Lua Unix) Alpha 0.01 Build 2208
Kernel: LKNU-lts (Lua Kernel is Not Unix)
lunix > help
Список команд:
cat      - Показать содержимое файла из папки luafs
clear    - Очистить экран
exit     - Выйти из оболочки
help     - Показать список команд
ls       - Показать файлы в папке luafs
rm       - Удалить файл из папки luafs
touch    - Создать пустой файл в папке luafs
version  - Показать версию системы
lunix > touch hello.txt
Создан файл: hello.txt
lunix > ls
hello.txt
lunix > cat hello.txt
lunix > rm hello.txt
Удалён файл: hello.txt
lunix > exit
```

Созданные во время работы файлы сохраняются в `luafs/`. Этот каталог является рабочими данными виртуальной файловой системы и не должен содержать файлы проекта.

## Команды оболочки

| Команда | Описание | Пример |
| --- | --- | --- |
| `help` | Показывает список загруженных команд | `help` |
| `version` | Показывает версию Lunix и условного ядра | `version` |
| `ls` | Показывает содержимое виртуального корня | `ls` |
| `touch` | Создаёт пустой файл | `touch file.txt` |
| `cat` | Показывает содержимое файла | `cat file.txt` |
| `rm` | Удаляет обычный файл | `rm file.txt` |
| `clear` | Очищает терминал и повторно показывает заголовок | `clear` |
| `exit` | Завершает работу оболочки | `exit` |

Команды являются отдельными Lua-файлами в каталоге `programs/`. При запуске shell автоматически находит Lua-файлы в этом каталоге и регистрирует таблицы команд с полями `name`, `desc` и `run`.

## API виртуальной файловой системы

Модуль `modules/fs.lua` создаёт файловую систему с корнем в `luafs/`:

```lua
local fs = require("modules.fs").new("luafs")
```

В текущей реализации модули загружаются через `loadfile`, поэтому при встраивании API в собственную программу рабочие пути должны соответствовать структуре репозитория.

### Основные методы

| Метод | Назначение |
| --- | --- |
| `fs.ensure()` | Создаёт физический каталог корня, если его нет |
| `fs.path(path)` | Возвращает host-путь для виртуального пути |
| `fs.list()` | Возвращает имена объектов в виртуальном корне |
| `fs.touch(path)` | Создаёт пустой файл |
| `fs.readFile(path)` | Читает файл целиком |
| `fs.remove(path)` | Удаляет обычный файл |

### Syscall-подобные операции

Все операции возвращают основной результат и, при ошибке, второй результат с кодом из `fs.errno`.

- `open(path, flags, mode)` — открыть или создать файл;
- `close(fd)` — закрыть файловый дескриптор;
- `read(fd, count)` — прочитать указанное число байтов;
- `write(fd, data)` — записать строку и вернуть число байтов;
- `lseek(fd, offset, whence)` — изменить позицию чтения/записи;
- `stat(path)` — получить тип и размер объекта;
- `fstat(fd)` — получить информацию по дескриптору;
- `unlink(path)` — удалить обычный файл;
- `rename(oldPath, newPath)` — переименовать или переместить объект;
- `mkdir(path, mode)` — создать каталог;
- `rmdir(path)` — удалить пустой каталог;
- `chdir(path)` — изменить виртуальный текущий каталог;
- `getcwd()` — получить текущий виртуальный каталог;
- `access(path, mode)` — проверить существование и права доступа;
- `opendir(path)` — открыть каталог для чтения;
- `readdir(directory)` — получить следующее имя объекта;
- `closedir(directory)` — закрыть каталог.

### Флаги и режимы

Константы доступны через `fs.constants`:

```lua
fs.constants.O_RDONLY
fs.constants.O_WRONLY
fs.constants.O_RDWR
fs.constants.O_CREAT
fs.constants.O_EXCL
fs.constants.O_TRUNC
fs.constants.O_APPEND

fs.constants.SEEK_SET
fs.constants.SEEK_CUR
fs.constants.SEEK_END

fs.constants.F_OK
fs.constants.R_OK
fs.constants.W_OK
fs.constants.X_OK
```

Поддерживаемые коды ошибок доступны через `fs.errno`, например `ENOENT`, `EACCES`, `EBADF`, `EEXIST`, `EINVAL`, `EISDIR`, `ENOTDIR`, `ENOTEMPTY` и `ESPIPE`.

Пример использования API:

```lua
local fsModule = dofile("modules/fs.lua")
local fs = fsModule.new("luafs")
local constants = fs.constants

local fd, openError = fs.open("example.txt", {
    constants.O_CREAT,
    constants.O_WRONLY,
    constants.O_TRUNC
})

if not fd then
    error(openError)
end

local written, writeError = fs.write(fd, "Hello from Lunix!\n")
if not written then
    fs.close(fd)
    error(writeError)
end

fs.close(fd)
```

## Структура проекта

```text
.
├── kernel.lua              # Точка входа и конфигурация системы
├── shell.lua               # Интерактивная оболочка
├── modules/
│   ├── fs.lua              # Виртуальная файловая система
│   └── syscalls/           # Реализации syscall-подобного API
├── programs/               # Команды оболочки
├── luafs/                  # Корень виртуальной файловой системы
├── meson.build             # Конфигурация запуска через Meson
└── LICENSE                 # Лицензия APSL 2.0
```

## Roadmap

Ближайшие направления развития проекта:

- добавление новых shell-команд;
- добавление новых syscall-подобных операций;
- расширение возможностей виртуальной файловой системы;
- улучшение совместимости с Unix-подобными системами.

## Вклад

Любой качественный и рабочий вклад приветствуется, включая экспериментальный vibe-код. Полные обязательные требования к проверке, безопасности, командам, syscall-модулям и pull request описаны в [CONTRIBUTING.md](CONTRIBUTING.md).

## Лицензия

Проект распространяется по лицензии [Apple Public Source License 2.0](LICENSE).
