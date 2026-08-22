project('lunix', version: '0.1.0', meson_version: '>=0.56')

lua = find_program('lua', 'lua5.4', 'lua5.3', required: true)
kernel = meson.project_source_root() / 'kernel.lua'

run_target(
    'run',
    command: ['env', 'LUNIX=1', 'LUNIX_TTY=1', lua, kernel],
)

message('Lua interpreter: ' + lua.full_path())
message('Run Lunix with: meson compile -C build run')