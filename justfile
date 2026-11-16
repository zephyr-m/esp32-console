# Пульт Saltic на ESP32 (экран SSD1306) — первый проект на tarantul.
# Дом Saltic — SALTIC_HOME (по умолчанию ~/dev/rnd/saltic): оттуда core, os,
# каталог пакетов и инструменты. `just` — привезти пакеты и собрать,
# `just flash` — залить на плату /dev/ttyUSB0.
set shell := ["bash", "-uc"]
export SALTIC_HOME := env_var_or_default("SALTIC_HOME", env_var("HOME") + "/dev/rnd/saltic")

build: get
    mkdir -p build
    "$SALTIC_HOME/.cache/build/workbench/esp32-toolchain" console.saltic build/pult.bin 65536

# инструменты Saltic: tarantul и сборщик ESP32 — компилятором с полки, в доме Saltic
tools:
    cd "$SALTIC_HOME" && mkdir -p .cache/build/workbench && bootstrap/saltic workbench/tarantul.saltic .cache/build/workbench/tarantul 268435456 x86_64 && bootstrap/saltic os/target/esp32/toolchain.saltic .cache/build/workbench/esp32-toolchain 536870912 x86_64

get: tools
    "$SALTIC_HOME/.cache/build/workbench/tarantul" get

flash: build
    nix-shell -p esptool --run "esptool --chip esp32 --port /dev/ttyUSB0 --no-stub write-flash 0x1000 build/pult.bin"
