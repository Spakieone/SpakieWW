#!/usr/bin/env bash
# tests.sh — раздел "Тесты и диагностика".

_t_run() { run_remote "$1" "$2"; pause; }

_t_ip_region() {
    log_info "Определяю регион IP..."
    pkg_install curl curl >/dev/null
    local ip; ip=$(curl -fsS --max-time 5 https://api.ipify.org || echo "—")
    local json; json=$(curl -fsS --max-time 5 "https://ipinfo.io/${ip}/json" 2>/dev/null || echo "")
    printf '\n  %sIP:%s        %s\n' "$C_BOLD" "$C_RESET" "$ip"
    if [[ -n "$json" ]]; then
        printf '  %sСтрана:%s    %s\n' "$C_BOLD" "$C_RESET" "$(grep -oP '"country":\s*"\K[^"]+' <<<"$json")"
        printf '  %sРегион:%s    %s\n' "$C_BOLD" "$C_RESET" "$(grep -oP '"region":\s*"\K[^"]+' <<<"$json")"
        printf '  %sГород:%s     %s\n' "$C_BOLD" "$C_RESET" "$(grep -oP '"city":\s*"\K[^"]+'   <<<"$json")"
        printf '  %sХостер:%s    %s\n' "$C_BOLD" "$C_RESET" "$(grep -oP '"org":\s*"\K[^"]+'    <<<"$json")"
    else
        log_warn "ipinfo.io недоступен."
    fi
    pause
}

_t_multitest() {
    # Запускает multitest и подсказывает, какой пункт выбрать.
    local hint="${1:-выбери нужный пункт в меню}"
    log_info "Подсказка: $hint"
    sleep 1
    bash <(curl -fsSL https://raw.githubusercontent.com/saveksme/multitest/master/multitest.sh) \
        || log_warn "multitest завершился с ошибкой."
    pause
}

_t_ip_check_place() { _t_multitest "В открывшемся меню выбери 'IP Check Place' (блокировки зарубежом)"; }
_t_ip_quality()     { _t_multitest "В открывшемся меню выбери 'IPQuality' (репутация IP)"; }
_t_censor_geo()     { _t_multitest "В открывшемся меню выбери 'Censorcheck — геоблок'"; }

_t_censor_dpi()     { _t_run "https://censorcheck.tlab.pw" "Censorcheck DPI РФ (tlab.pw)"; }

_t_iperf_ru()       { _t_run "https://bench.tlab.pw" "iPerf3 → серверы РФ"; }
_t_speed_world()    { _t_run "https://speed.tlab.pw" "Speedtest → US/EU/Asia"; }

_t_yabs() {
    log_info "Запускаю YABS — это займёт 5–10 минут."
    pkg_install curl curl >/dev/null
    bash <(curl -fsSL yabs.sh) || log_warn "YABS завершился с ошибкой."
    pause
}

_t_sysbench() {
    pkg_install sysbench sysbench
    log_info "sysbench CPU (10 сек, 1 поток)..."
    sysbench cpu --cpu-max-prime=20000 --time=10 --threads=1 run \
        | grep -E 'events per second|total time|min:|avg:|max:'
    pause
}

tests_menu() {
    while true; do
        draw_header "Тесты и диагностика" "Главная › Тесты"

        section "IP и репутация"
        menu_item 1  "🌍" "IP Region"           "Определение страны, региона, города и хостера сервера."
        menu_item 2  "🚫" "IP Check Place"      "Проверка блокировок IP зарубежными сервисами (Netflix, OpenAI и др.)."
        menu_item 3  "🛡" "IPQuality"           "Оценка репутации IP: спам, прокси, VPN, мошенничество."

        section "Цензура / DPI"
        menu_item 4  "🔍" "Censorcheck геоблок" "Проверка географических блокировок популярных сервисов."
        menu_item 5  "🇷🇺" "Censorcheck DPI РФ"  "Проверка блокировок РКН на уровнях DNS, IP, HTTP, DPI."

        section "Скорость и пропускная"
        menu_item 6  "🇷🇺" "iPerf3 → РФ"         "Тест пропускной способности до российских серверов."
        menu_item 7  "🌐" "Speedtest → US/EU/AS" "Тест скорости до серверов США, Европы и Азии."

        section "Бенчмарк железа"
        menu_item 8  "⚡" "YABS"                "Полный бенчмарк сервера: диск, сеть, CPU (5–10 минут)."
        menu_item 9  "🧮" "sysbench CPU"        "Быстрый однопоточный тест производительности процессора."

        draw_line
        menu_item 0  "↩" "Назад"               "Вернуться в главное меню."
        draw_line

        local ch; prompt "Выбор:" ch
        case "$ch" in
            1)  _t_ip_region ;;
            2)  _t_ip_check_place ;;
            3)  _t_ip_quality ;;
            4)  _t_censor_geo ;;
            5)  _t_censor_dpi ;;
            6)  _t_iperf_ru ;;
            7)  _t_speed_world ;;
            8)  _t_yabs ;;
            9)  _t_sysbench ;;
            0|q|Q|"") return 0 ;;
            *) log_warn "Нет такого пункта."; sleep 0.8 ;;
        esac
    done
}
