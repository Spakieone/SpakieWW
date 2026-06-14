#!/usr/bin/env bash
# install.sh — установки и защита.

_i_node_accelerator() {
    need_root || { pause; return; }
    log_info "Node-Accelerator ставит XanMod-ядро + BBRv3 + nftables + CrowdSec."
    log_warn "Замена ядра требует перезагрузки сервера."
    prompt "Продолжить? [y/N]:" ans
    [[ "$ans" =~ ^[yYдД] ]] || return
    bash <(curl -fsSL https://raw.githubusercontent.com/jestivald/node-accelerator/main/install.sh) \
        || log_warn "Установщик завершился с ошибкой."
    pause
}

_i_trafficguard() {
    need_root || { pause; return; }
    log_info "TrafficGuard-auto — защита от сканеров (ipset + iptables)."
    bash <(curl -fsSL https://raw.githubusercontent.com/DonMatteoVPN/TrafficGuard-auto/main/install.sh) \
        || log_warn "Установщик завершился с ошибкой."
    log_info "После установки запуск: rknpidor"
    pause
}

install_menu() {
    while true; do
        draw_header "Установки и защита" "Главная › Установки"

        section "Ядро и сеть"
        menu_item 1 "🚀" "Node-Accelerator" "XanMod+BBRv3+nftables+CrowdSec"

        section "Защита трафика"
        menu_item 2 "🛡" "TrafficGuard-auto" "защита от сканеров портов"

        draw_line
        menu_item 0 "↩" "Назад" ""
        draw_line

        local ch; prompt "Выбор:" ch
        case "$ch" in
            1) _i_node_accelerator ;;
            2) _i_trafficguard ;;
            0|q|Q|"") return 0 ;;
            *) log_warn "Нет такого пункта."; sleep 0.8 ;;
        esac
    done
}
