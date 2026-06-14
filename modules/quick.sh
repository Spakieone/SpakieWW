#!/usr/bin/env bash
# quick.sh — полезные быстрые команды.

_q_btop() {
    pkg_install btop btop || pkg_install htop htop
    if has_cmd btop; then btop; else htop; fi
}

_q_nethogs() {
    need_root || { pause; return; }
    pkg_install nethogs nethogs
    nethogs
}

_q_iftop() {
    need_root || { pause; return; }
    pkg_install iftop iftop
    iftop
}

_q_iotop() {
    need_root || { pause; return; }
    pkg_install iotop iotop
    iotop -o
}

_q_top_proc() {
    section "Топ-10 процессов по CPU"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 11
    section "Топ-10 процессов по RAM"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11
    pause
}

_q_disk() {
    section "Использование разделов (df -h)"
    df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs 2>/dev/null \
        || df -h
    section "Топ-10 крупных папок в / (может быть долго)"
    du -h --max-depth=2 / 2>/dev/null | sort -hr | head -n 10
    pause
}

_q_uptime() {
    uptime
    printf '\n'
    if has_cmd w; then w; fi
    pause
}

_q_logs_size() {
    section "Размер journal"
    journalctl --disk-usage 2>/dev/null || log_warn "journalctl недоступен."
    section "Топ-10 файлов в /var/log"
    du -ah /var/log 2>/dev/null | sort -hr | head -n 10
    pause
}

_q_ports() {
    section "Слушающие порты (ss -tulpn)"
    ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null
    pause
}

_q_connections() {
    section "Активные TCP-соединения"
    ss -tnp state established 2>/dev/null | head -n 30 \
        || netstat -tnp 2>/dev/null | head -n 30
    pause
}

_q_ssh_sessions() {
    section "Кто залогинен сейчас"
    who
    section "Последние входы (last -n 10)"
    last -n 10
    section "Неуспешные попытки SSH"
    if [[ -r /var/log/auth.log ]]; then
        grep -i 'failed password' /var/log/auth.log 2>/dev/null | tail -n 10
    elif has_cmd journalctl; then
        journalctl _COMM=sshd 2>/dev/null | grep -i 'failed password' | tail -n 10
    fi
    pause
}

_q_ext_ip() {
    pkg_install curl curl >/dev/null
    section "Внешний IP"
    curl -fsS --max-time 5 https://api.ipify.org && echo
    section "Резолв DNS (1.1.1.1, 8.8.8.8)"
    for d in cloudflare.com google.com github.com; do
        printf '  %-20s → ' "$d"
        if has_cmd dig; then
            dig +short +time=2 +tries=1 "$d" | head -n1
        else
            getent hosts "$d" | awk '{print $1}' | head -n1
        fi
    done
    pause
}

_q_docker_ps() {
    has_cmd docker || { log_warn "Docker не установлен."; pause; return; }
    section "docker ps"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    pause
}

_q_docker_logs() {
    has_cmd docker || { log_warn "Docker не установлен."; pause; return; }
    local names; names=$(docker ps --format '{{.Names}}')
    [[ -z "$names" ]] && { log_warn "Нет запущенных контейнеров."; pause; return; }
    section "Контейнеры"
    local i=1 arr=()
    while IFS= read -r n; do
        printf '  %2d) %s\n' "$i" "$n"
        arr+=("$n"); i=$((i+1))
    done <<<"$names"
    prompt "Номер контейнера (0 — отмена):" ch
    [[ "$ch" =~ ^[0-9]+$ ]] || return
    (( ch == 0 || ch > ${#arr[@]} )) && return
    log_info "Логи ${arr[$((ch-1))]} (Ctrl+C — выход):"
    docker logs --tail 200 -f "${arr[$((ch-1))]}" || true
}

_q_docker_stats() {
    has_cmd docker || { log_warn "Docker не установлен."; pause; return; }
    log_info "Ctrl+C для выхода."
    docker stats
}

_q_docker_prune() {
    has_cmd docker || { log_warn "Docker не установлен."; pause; return; }
    log_warn "Будут удалены остановленные контейнеры, неиспользуемые образы и сети."
    prompt "Продолжить? [y/N]:" ans
    [[ "$ans" =~ ^[yYдД] ]] || return
    docker system prune -af
    pause
}

_q_journal_errors() {
    has_cmd journalctl || { log_warn "journalctl недоступен."; pause; return; }
    section "Последние ошибки (journalctl -p err -n 50)"
    journalctl -p err -n 50 --no-pager
    pause
}

_q_dmesg() {
    section "dmesg (последние 50 строк)"
    dmesg -T 2>/dev/null | tail -n 50 || dmesg | tail -n 50
    pause
}

quick_menu() {
    while true; do
        draw_header "Полезные команды" "Главная › Полезные"

        section "Мониторинг в реальном времени"
        menu_item 1 "📈" "btop / htop"     "что грузит систему"
        menu_item 2 "📡" "nethogs"         "трафик по процессам"
        menu_item 3 "📊" "iftop"           "трафик по соединениям"
        menu_item 4 "💾" "iotop"           "I/O по процессам"

        section "Состояние"
        menu_item 5 "🔝" "Топ процессов"   "CPU + RAM"
        menu_item 6 "💽" "Использование диска" "df + du"
        menu_item 7 "⏱" "Uptime / who"    "кто залогинен"
        menu_item 8 "📦" "Размер логов"    "journal + /var/log"

        section "Сеть"
        menu_item 9  "🔌" "Занятые порты"   "ss -tulpn"
        menu_item 10 "🌐" "TCP-соединения"  "established"
        menu_item 11 "🔐" "SSH сессии"      "who + last + failed"
        menu_item 12 "🌍" "Внешний IP / DNS" "проверка резолва"

        section "Docker"
        menu_item 13 "🐳" "docker ps"      "список контейнеров"
        menu_item 14 "📜" "Логи контейнера" "выбрать из списка"
        menu_item 15 "📈" "docker stats"   "ресурсы контейнеров"
        menu_item 16 "🧹" "system prune"   "очистить мусор"

        section "Логи системы"
        menu_item 17 "🚨" "Ошибки journal"  "p err -n 50"
        menu_item 18 "🧠" "dmesg"          "события ядра"

        draw_line
        menu_item 0 "↩" "Назад" ""
        draw_line

        local ch; prompt "Выбор:" ch
        case "$ch" in
            1)  _q_btop ;;
            2)  _q_nethogs ;;
            3)  _q_iftop ;;
            4)  _q_iotop ;;
            5)  _q_top_proc ;;
            6)  _q_disk ;;
            7)  _q_uptime ;;
            8)  _q_logs_size ;;
            9)  _q_ports ;;
            10) _q_connections ;;
            11) _q_ssh_sessions ;;
            12) _q_ext_ip ;;
            13) _q_docker_ps ;;
            14) _q_docker_logs ;;
            15) _q_docker_stats ;;
            16) _q_docker_prune ;;
            17) _q_journal_errors ;;
            18) _q_dmesg ;;
            0|q|Q|"") return 0 ;;
            *) log_warn "Нет такого пункта."; sleep 0.8 ;;
        esac
    done
}
