#!/usr/bin/env bash
# utils.sh — общие функции: цвета, UI, навигация, проверки.

# ---------- Цвета ----------
if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_MAGENTA=$'\033[35m'
    C_CYAN=$'\033[36m'
    C_WHITE=$'\033[37m'
    C_GRAY=$'\033[90m'
else
    C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW=''
    C_BLUE='' C_MAGENTA='' C_CYAN='' C_WHITE='' C_GRAY=''
fi

# ---------- Логи ----------
log_info()  { printf '%s[i]%s %s\n' "$C_CYAN"   "$C_RESET" "$*"; }
log_ok()    { printf '%s[+]%s %s\n' "$C_GREEN"  "$C_RESET" "$*"; }
log_warn()  { printf '%s[!]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
log_err()   { printf '%s[x]%s %s\n' "$C_RED"    "$C_RESET" "$*"; }

# ---------- Проверки ----------
is_root()       { [[ $EUID -eq 0 ]]; }
has_cmd()       { command -v "$1" >/dev/null 2>&1; }
need_root() {
    if ! is_root; then
        log_err "Нужны root-права. Запусти через sudo."
        return 1
    fi
}

# ---------- Установка пакетов (молча, авто) ----------
pkg_install() {
    # pkg_install <bin> <apt-package>
    local bin="$1" pkg="${2:-$1}"
    has_cmd "$bin" && return 0
    log_info "Устанавливаю $pkg..."
    if has_cmd apt-get; then
        DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >/dev/null 2>&1
    elif has_cmd dnf; then
        dnf install -y -q "$pkg" >/dev/null 2>&1
    elif has_cmd yum; then
        yum install -y -q "$pkg" >/dev/null 2>&1
    else
        log_err "Пакетный менеджер не найден."
        return 1
    fi
    has_cmd "$bin" || { log_err "Не удалось установить $pkg"; return 1; }
}

# ---------- UI ----------
TERM_WIDTH() { tput cols 2>/dev/null || echo 80; }

draw_line() {
    local color="${1:-$C_GRAY}"
    local w; w=$(TERM_WIDTH)
    local line=""
    local i=0
    while (( i < w )); do line+="─"; i=$((i+1)); done
    printf '%s%s%s\n' "$color" "$line" "$C_RESET"
}

draw_header() {
    # draw_header <title> <breadcrumb>
    local title="$1" crumb="$2"
    clear
    printf '\n'
    printf '  %s%s███████╗██████╗  █████╗ ██╗  ██╗██╗███████╗%s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '  %s%s██╔════╝██╔══██╗██╔══██╗██║ ██╔╝██║██╔════╝%s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '  %s%s███████╗██████╔╝███████║█████╔╝ ██║█████╗  %s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '  %s%s╚════██║██╔═══╝ ██╔══██║██╔═██╗ ██║██╔══╝  %s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '  %s%s███████║██║     ██║  ██║██║  ██╗██║███████╗%s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '  %s%s╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝%s\n' "$C_BOLD" "$C_CYAN" "$C_RESET"
    printf '\n'
    if [[ -n "$crumb" ]]; then
        printf '  %s%s%s\n' "$C_DIM" "$crumb" "$C_RESET"
    fi
    if [[ -n "$title" ]]; then
        printf '  %s%s%s\n' "$C_BOLD" "$title" "$C_RESET"
    fi
    draw_line
}

section() {
    printf '\n  %s%s%s\n' "$C_BOLD$C_YELLOW" "$1" "$C_RESET"
}

menu_item() {
    # menu_item <num> <icon> <label> <hint>
    printf '  %s%2s.%s %s %-28s %s%s%s\n' \
        "$C_BOLD" "$1" "$C_RESET" \
        "$2" "$3" \
        "$C_DIM" "${4:+— $4}" "$C_RESET"
}

# ---------- Навигация ----------
pause() {
    printf '\n  %s%s%s' "$C_DIM" "Нажмите Enter для возврата..." "$C_RESET"
    read -r _ || true
}

prompt() {
    # prompt <text> <varname>
    local text="$1" __var="$2" __ans
    printf '\n  %s%s%s ' "$C_BOLD" "$text" "$C_RESET"
    read -r __ans || true
    printf -v "$__var" '%s' "$__ans"
}

# Запуск внешнего скрипта (curl|bash) с защитой возврата.
run_remote() {
    # run_remote <url> [title]
    local url="$1" title="${2:-скрипт}"
    log_info "Запускаю: $title"
    printf '  %sИсточник:%s %s\n\n' "$C_DIM" "$C_RESET" "$url"
    bash <(curl -fsSL "$url") || log_warn "Скрипт завершился с ошибкой."
}

# Trap для Ctrl+C внутри подменю — не убиваем весь процесс.
trap_back() {
    trap 'echo; return 0' INT
}
