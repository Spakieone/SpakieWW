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
    local f="" e=""
    local i=0
    while (( i < filled )); do f+="▰"; i=$((i+1)); done
    i=0
    while (( i < empty  )); do e+="▱"; i=$((i+1)); done
    printf '%s%s%s%s%s' "$color" "$f" "$C_DIM" "$e" "$C_RESET"
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

_info_section() {
    # Пустая строка (с │) и заголовок секции с │ слева.
    printf '  %s│%s\n'                    "$C_GRAY" "$C_RESET"
    printf '  %s│%s %s%s%s\n'             "$C_GRAY" "$C_RESET" "$C_BOLD$C_YELLOW" "$1" "$C_RESET"
}

_info_row() {
    # _info_row <label> <value>
    # │  Метка     ▸ Значение
    # printf %-Ns считает байты, а кириллица в UTF-8 занимает 2 байта на символ —
    # отсюда едет вертикаль. Добиваем пробелы вручную по числу символов.
    local label="$1" value="$2"
    local width=10
    local len; len=$(printf '%s' "$label" | wc -m)
    local pad=$(( width - len ))
    (( pad < 0 )) && pad=0
    local spaces=""
    while (( pad > 0 )); do spaces+=" "; pad=$((pad-1)); done
    printf '  %s│%s  %s%s%s%s %s▸%s %s\n' \
        "$C_GRAY" "$C_RESET" \
        "$C_CYAN" "$label" "$C_RESET" "$spaces" \
        "$C_DIM" "$C_RESET" \
        "$value"
}

info_compact() {
    _info_collect_ip
    local cpu mem_p mem_used mem_total disk_p disk_used disk_total
    cpu=$(_info_cpu_load)
    read -r mem_p mem_used mem_total <<<"$(_info_mem)"
    read -r disk_p disk_used disk_total <<<"$(_info_disk)"
    local du dt
    du=$(_info_human_size "$disk_used"); dt=$(_info_human_size "$disk_total")

    _info_section "СИСТЕМА"
    _info_row "ОС"     "$(_info_os)"
    _info_row "Аптайм" "$(_info_uptime)"
    _info_row "Virt"   "$(_info_virt)"
    _info_row "IP"     "$(printf '%s %s(%s)%s' "${_INFO_IP_CACHE}" "$C_DIM" "${_INFO_GEO_CACHE}" "$C_RESET")"
    _info_row "Хостер" "${_INFO_ASN_CACHE}"

    _info_section "ЖЕЛЕЗО"
    local mem_str disk_str cpu_pct mem_pct disk_pct
    mem_str=$(printf '%s / %s' "$mem_used" "$mem_total")
    disk_str=$(printf '%s / %s' "$du" "$dt")
    # Процент строго 4 символа: "  2%", " 25%", "100%" — следующая колонка не едет.
    cpu_pct=$(printf '%3d%%' "$cpu")
    mem_pct=$(printf '%3d%%' "$mem_p")
    disk_pct=$(printf '%3d%%' "$disk_p")
    _info_row "CPU"  "$(printf '%s %s  %s%s%s'   "$(_info_bar "$cpu"    8)" "$cpu_pct"  "$C_DIM" "$(_info_cpu_model)" "$C_RESET")"
    _info_row "RAM"  "$(printf '%s %s  %s'       "$(_info_bar "$mem_p"  8)" "$mem_pct"  "$mem_str")"
    _info_row "Disk" "$(printf '%s %s  %s'       "$(_info_bar "$disk_p" 8)" "$disk_pct" "$disk_str")"

    _info_section "STATUS"
    _info_row "Remnanode" "$(_info_remnanode_status)"
    local containers; containers=$(_info_docker_containers)
    [[ -n "$containers" ]] && _info_row "Docker" "$containers"
    printf '  %s│%s\n' "$C_GRAY" "$C_RESET"
}

