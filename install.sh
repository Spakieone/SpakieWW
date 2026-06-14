#!/usr/bin/env bash
# install.sh — установщик SpakieWW.
# Запуск: bash <(curl -fsSL https://raw.githubusercontent.com/Spakieone/SpakieWW/main/install.sh)

set -euo pipefail

REPO="https://github.com/Spakieone/SpakieWW.git"
BRANCH="${SPAKIE_BRANCH:-main}"
DEST="/opt/spakieww"
BIN="/usr/local/bin/spakie"

c_g=$'\033[32m'; c_y=$'\033[33m'; c_r=$'\033[31m'; c_c=$'\033[36m'; c_n=$'\033[0m'
say() { printf '%s[+]%s %s\n' "$c_g" "$c_n" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_y" "$c_n" "$*"; }
die()  { printf '%s[x]%s %s\n' "$c_r" "$c_n" "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Запусти через sudo / от root."

have() { command -v "$1" >/dev/null 2>&1; }

# Зависимости для установщика и базового функционала.
ensure_deps() {
    local need=()
    have git    || need+=(git)
    have curl   || need+=(curl)
    have tput   || need+=(ncurses-bin)
    if (( ${#need[@]} )); then
        say "Ставлю зависимости: ${need[*]}"
        if   have apt-get; then
            DEBIAN_FRONTEND=noninteractive apt-get update -qq
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${need[@]}"
        elif have dnf; then dnf install -y -q "${need[@]}"
        elif have yum; then yum install -y -q "${need[@]}"
        else die "Не нашёл apt/dnf/yum — поставь git/curl вручную."
        fi
    fi
}

ensure_deps

if [[ -d "$DEST/.git" ]]; then
    say "Обновляю $DEST"
    git -C "$DEST" fetch --quiet origin "$BRANCH"
    git -C "$DEST" reset --quiet --hard "origin/$BRANCH"
else
    say "Клонирую $REPO → $DEST"
    rm -rf "$DEST"
    git clone --quiet --branch "$BRANCH" --depth 1 "$REPO" "$DEST"
fi

chmod +x "$DEST/main.sh"
find "$DEST/modules" -type f -name '*.sh' -exec chmod +x {} \;

# Симлинк команды spakie.
ln -sf "$DEST/main.sh" "$BIN"
say "Команда установлена: $BIN"

say "SpakieWW установлен. Запускаю..."
sleep 1

# Запускаем меню в текущем терминале. Если stdin не TTY (curl|bash без <()),
# подсовываем /dev/tty, иначе read внутри меню не сработает.
if [[ -t 0 ]]; then
    exec "$BIN"
else
    exec "$BIN" </dev/tty
fi
