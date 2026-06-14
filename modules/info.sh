#!/usr/bin/env bash
# info.sh — информационный блок о сервере (компактный и полный).

# Кеш внешнего IP/гео на сессию, чтобы не дёргать сеть каждый раз.
_INFO_IP_CACHE=""
_INFO_GEO_CACHE=""
_INFO_ASN_CACHE=""

_info_human_size() {
    # Принимает байты → человекочитаемо.
    local b="${1:-0}"
    awk -v b="$b" 'BEGIN{
        s="B KB MB GB TB PB"; split(s,u," "); i=1;
        while (b>=1024 && i<6){ b/=1024; i++ }
        printf (b>=10?"%.0f%s":"%.1f%s"), b, u[i]
    }'
}

_info_bar() {
    # _info_bar <percent> <width>
    local p="${1:-0}" w="${2:-12}"
    [[ "$p" =~ ^[0-9]+$ ]] || p=0
    (( p > 100 )) && p=100
    local filled=$(( p * w / 100 ))
    local empty=$(( w - filled ))
    local color="$C_GREEN"
    (( p >= 60 )) && color="$C_YELLOW"
    (( p >= 85 )) && color="$C_RED"
    printf '%s[' "$C_DIM"
    printf '%s' "$color"
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf '%s' "$C_DIM"
    printf '%*s' "$empty" '' | tr ' ' '░'
    printf ']%s' "$C_RESET"
}

_info_collect_ip() {
    [[ -n "$_INFO_IP_CACHE" ]] && return 0
    _INFO_IP_CACHE=$(curl -fsS --max-time 3 https://api.ipify.org 2>/dev/null \
                  || curl -fsS --max-time 3 https://ifconfig.me 2>/dev/null \
                  || echo "—")
    if [[ "$_INFO_IP_CACHE" != "—" ]]; then
        local raw
        raw=$(curl -fsS --max-time 3 "https://ipinfo.io/${_INFO_IP_CACHE}/json" 2>/dev/null || echo "")
        if [[ -n "$raw" ]]; then
            _INFO_GEO_CACHE=$(grep -oP '"country":\s*"\K[^"]+' <<<"$raw" | head -n1)
            _INFO_ASN_CACHE=$(grep -oP '"org":\s*"\K[^"]+'     <<<"$raw" | head -n1)
        fi
    fi
    : "${_INFO_GEO_CACHE:=—}"
    : "${_INFO_ASN_CACHE:=—}"
}

_info_uptime() {
    local up; up=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
    local d=$((up/86400)) h=$(( (up%86400)/3600 )) m=$(( (up%3600)/60 ))
    printf '%dд %dч %dм' "$d" "$h" "$m"
}

_info_os() {
    local name="?" kernel
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        name="${PRETTY_NAME:-$NAME}"
    fi
    kernel=$(uname -r)
    printf '%s (%s)' "$name" "$kernel"
}

_info_virt() {
    if has_cmd systemd-detect-virt; then
        local v; v=$(systemd-detect-virt 2>/dev/null)
        [[ -z "$v" || "$v" == "none" ]] && echo "Bare-metal" || echo "$v"
    else
        echo "—"
    fi
}

_info_cpu_model() {
    grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//' \
        || echo "—"
}

_info_cpu_cores() { nproc 2>/dev/null || echo 1; }

_info_cpu_load() {
    # Возвращает % загрузки за 1 сек на основе /proc/stat.
    local a b idle_a idle_b total_a total_b
    read -r _ a <<<"$(grep '^cpu ' /proc/stat)"
    local arr=($a); idle_a=${arr[3]}
    total_a=0; for v in "${arr[@]}"; do total_a=$((total_a+v)); done
    sleep 0.4
    read -r _ b <<<"$(grep '^cpu ' /proc/stat)"
    arr=($b); idle_b=${arr[3]}
    total_b=0; for v in "${arr[@]}"; do total_b=$((total_b+v)); done
    local d_idle=$((idle_b-idle_a)) d_total=$((total_b-total_a))
    (( d_total <= 0 )) && { echo 0; return; }
    echo $(( (d_total - d_idle) * 100 / d_total ))
}

_info_mem() {
    # Эхо: percent used_human total_human
    local total used
    total=$(awk '/MemTotal/{print $2*1024}' /proc/meminfo)
    local avail
    avail=$(awk '/MemAvailable/{print $2*1024}' /proc/meminfo)
    used=$(( total - avail ))
    local p=0
    (( total > 0 )) && p=$(( used * 100 / total ))
    printf '%s %s %s' "$p" "$(_info_human_size "$used")" "$(_info_human_size "$total")"
}

_info_disk() {
    # Корневой раздел.
    df -B1 / 2>/dev/null | awk 'NR==2{printf "%d %d %d", int($3*100/$2), $3, $2}'
}

_info_docker_containers() {
    has_cmd docker || { echo ""; return; }
    docker ps --format '{{.Names}}' 2>/dev/null | paste -sd ',' -
}

_info_remnanode_status() {
    if has_cmd docker && docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^remnanode$'; then
        local img ver
        img=$(docker inspect --format '{{.Config.Image}}' remnanode 2>/dev/null)
        ver="${img##*:}"
        [[ -z "$ver" || "$ver" == "$img" ]] && ver="latest"
        printf '%sАктивна%s (%s)' "$C_GREEN" "$C_RESET" "$ver"
    else
        printf '%sНе установлена%s' "$C_DIM" "$C_RESET"
    fi
}

# ---------- Публичные API ----------

info_compact() {
    # Краткая строка для шапки главного меню.
    local cpu mem_p mem_used mem_total disk_p disk_used disk_total
    cpu=$(_info_cpu_load)
    read -r mem_p mem_used mem_total <<<"$(_info_mem)"
    read -r disk_p disk_used disk_total <<<"$(_info_disk)"
    local disk_used_h disk_total_h
    disk_used_h=$(_info_human_size "$disk_used")
    disk_total_h=$(_info_human_size "$disk_total")
    local node; node=$(_info_remnanode_status)

    printf '  %sCPU%s %s %3s%%   %sRAM%s %s %3s%% %s/%s   %sDisk%s %s %3s%% %s/%s\n' \
        "$C_BOLD" "$C_RESET" "$(_info_bar "$cpu" 10)" "$cpu" \
        "$C_BOLD" "$C_RESET" "$(_info_bar "$mem_p" 10)" "$mem_p" "$mem_used" "$mem_total" \
        "$C_BOLD" "$C_RESET" "$(_info_bar "$disk_p" 10)" "$disk_p" "$disk_used_h" "$disk_total_h"
    printf '  %sRemnanode:%s %s\n' "$C_BOLD" "$C_RESET" "$node"
}

info_full() {
    draw_header "Информация о сервере" "Главная › Инфо"
    _info_collect_ip

    local cpu mem_p mem_used mem_total disk_p disk_used disk_total
    cpu=$(_info_cpu_load)
    read -r mem_p mem_used mem_total <<<"$(_info_mem)"
    read -r disk_p disk_used disk_total <<<"$(_info_disk)"

    section "СИСТЕМА"
    printf '  %-16s %s\n' "ОС / Ядро"  "$(_info_os)"
    printf '  %-16s %s\n' "Аптайм"      "$(_info_uptime)"
    printf '  %-16s %s\n' "Виртуализация" "$(_info_virt)"
    printf '  %-16s %s  %s[%s]%s\n' "IP / Гео" "${_INFO_IP_CACHE}" "$C_DIM" "${_INFO_GEO_CACHE}" "$C_RESET"
    printf '  %-16s %s\n' "Хостер" "${_INFO_ASN_CACHE}"

    section "ЖЕЛЕЗО"
    printf '  %-16s %s\n' "CPU модель" "$(_info_cpu_model)"
    printf '  %-16s %s %3s%% (%s ядер)\n' \
        "Загрузка CPU" "$(_info_bar "$cpu" 14)" "$cpu" "$(_info_cpu_cores)"
    printf '  %-16s %s %3s%% (%s / %s)\n' \
        "Память (RAM)" "$(_info_bar "$mem_p" 14)" "$mem_p" "$mem_used" "$mem_total"
    local du dt
    du=$(_info_human_size "$disk_used"); dt=$(_info_human_size "$disk_total")
    printf '  %-16s %s %3s%% (%s / %s)\n' \
        "Диск /" "$(_info_bar "$disk_p" 14)" "$disk_p" "$du" "$dt"

    section "СТАТУС"
    printf '  %-16s %s\n' "Remnanode" "$(_info_remnanode_status)"
    local containers; containers=$(_info_docker_containers)
    if [[ -n "$containers" ]]; then
        printf '  %-16s %s\n' "Контейнеры" "$containers"
    fi
    draw_line
    pause
}
