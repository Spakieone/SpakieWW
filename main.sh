#!/usr/bin/env bash
# main.sh — главное меню SpakieWW.
# Запуск: spakie  (после установки через install.sh)

set -u

SPAKIE_VERSION="1.0.0"
SPAKIE_DIR="${SPAKIE_DIR:-/opt/spakieww}"
# Если запущено локально из git-клона — используем каталог скрипта.
if [[ ! -d "$SPAKIE_DIR/modules" ]]; then
    SPAKIE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# shellcheck source=modules/utils.sh
source "$SPAKIE_DIR/modules/utils.sh"
# shellcheck source=modules/info.sh
source "$SPAKIE_DIR/modules/info.sh"
# shellcheck source=modules/quick.sh
source "$SPAKIE_DIR/modules/quick.sh"
# shellcheck source=modules/tests.sh
source "$SPAKIE_DIR/modules/tests.sh"
# shellcheck source=modules/install.sh
source "$SPAKIE_DIR/modules/install.sh"
# shellcheck source=modules/remnawave.sh
source "$SPAKIE_DIR/modules/remnawave.sh"

main_menu() {
    trap 'echo; printf "\n  %sДо встречи.%s\n" "$C_CYAN" "$C_RESET"; exit 0' INT
    while true; do
        draw_header "ГЛАВНОЕ МЕНЮ" ""
        info_compact
        draw_line

        section "РАЗДЕЛЫ"
        menu_item 1 "🔍" "Полезные команды"      "btop, порты, docker, логи"
        menu_item 2 "📊" "Тесты и диагностика"   "IP, censorcheck, speed, YABS"
        menu_item 3 "🚀" "Установки и защита"    "Node-Accelerator, TrafficGuard"
        menu_item 4 "🎛" "Remnawave / Remnanode" "RemnaSetup, Reshala, Grace"

        draw_line
        menu_item 0 "⏻" "Выход" ""
        draw_line
        printf '  %sv%s%s\n' "$C_DIM" "$SPAKIE_VERSION" "$C_RESET"

        local ch; prompt "Выбор:" ch
        case "$ch" in
            1) quick_menu ;;
            2) tests_menu ;;
            3) install_menu ;;
            4) remnawave_menu ;;
            0|q|Q|exit) printf '\n  %sДо встречи.%s\n' "$C_CYAN" "$C_RESET"; exit 0 ;;
            "") ;;
            *) log_warn "Нет такого пункта."; sleep 0.8 ;;
        esac
    done
}

main_menu
