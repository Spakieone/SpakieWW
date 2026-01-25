#!/usr/bin/env bash
set -uo pipefail

# ============================================
# SCRIPTS by Spakie
# ============================================

# Проверка root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите скрипт от root (sudo)."
    exit 1
fi

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================
# ШАПКА
# ============================================
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}███████║╚██████╗██║  ██║██║██║        ██║   ███████║${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                      ${YELLOW}by Spakie${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================
# ГЛАВНОЕ МЕНЮ
# ============================================
show_main_menu() {
    show_header
    
    # Проверяем статусы сервисов
    local tblocker_status="${RED}○${NC}"
    if systemctl is-active --quiet tblocker 2>/dev/null; then
        tblocker_status="${GREEN}●${NC}"
    elif [[ -f /opt/tblocker/tblocker ]]; then
        tblocker_status="${YELLOW}○${NC}"
    fi
    
    local zapret_status="${RED}○${NC}"
    if systemctl is-active --quiet zapret 2>/dev/null; then
        zapret_status="${GREEN}●${NC}"
    elif [[ -d /opt/zapret ]]; then
        zapret_status="${YELLOW}○${NC}"
    fi
    
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🛠️  ГЛАВНОЕ МЕНЮ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${CYAN}Статус:${NC} TBlocker ${tblocker_status}  Zapret ${zapret_status}"
    echo ""
    echo -e "  ${GREEN}1.${NC} ${YELLOW}💡 Полезные команды${NC}        — тесты, статус, логи"
    echo -e "  ${GREEN}2.${NC} ${YELLOW}⚙️  Настройка сервера${NC}       — UFW, SSH, BBR, Swap"
    echo -e "  ${GREEN}3.${NC} ${YELLOW}🔧 Утилиты${NC}                 — TBlocker, Zapret"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}4.${NC} ${YELLOW}🚀 Установка Remna${NC}         — Panel/Node by Capybara"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}0.${NC} ${WHITE}Выход${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}Выберите пункт: ${NC}"
}

# ============================================
# ПОЛЕЗНЫЕ КОМАНДЫ
# ============================================
show_useful_menu() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  💡 ПОЛЕЗНЫЕ КОМАНДЫ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} ${YELLOW}⚡ Обновить систему${NC}         — apt update && upgrade"
    echo -e "  ${GREEN}2.${NC} ${YELLOW}🌍 Тест на локацию${NC}         — IP region check"
    echo -e "  ${GREEN}3.${NC} ${YELLOW}🚫 Проверка блокировок${NC}     — IP.Check.Place"
    echo -e "  ${GREEN}4.${NC} ${YELLOW}🏠 Скорость к РФ${NC}           — Russian providers"
    echo -e "  ${GREEN}5.${NC} ${YELLOW}🚀 Скорость к зарубежным${NC}   — International providers"
    echo -e "  ${GREEN}6.${NC} ${YELLOW}📱 Проверка Instagram${NC}      — Audio block check"
    echo -e "  ${GREEN}7.${NC} ${YELLOW}📺 Проверка медиа-сервисов${NC} — Netflix, YouTube, etc."
    echo -e "  ${GREEN}8.${NC} ${YELLOW}🖥️  YABS тест сервера${NC}       — CPU, диск, сеть"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}9.${NC} ${YELLOW}🌐 Сеть и порты${NC}            — IP и слушающие порты"
    echo -e "  ${GREEN}10.${NC} ${YELLOW}🐳 Docker статус${NC}           — контейнеры"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}0.${NC} ${WHITE}Назад${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}Выберите пункт: ${NC}"
}

# ============================================
# НАСТРОЙКА СЕРВЕРА
# ============================================
show_server_menu() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  ⚙️  НАСТРОЙКА СЕРВЕРА${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC}  ${RED}⚡ БЫСТРАЯ НАСТРОЙКА НОДЫ${NC}  — IPv6 off, BBR, UFW, hostname"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  📦 БАЗОВОЕ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}2.${NC}  ${YELLOW}📦 Базовые пакеты${NC}         — curl, git, htop, jq и др."
    echo -e "  ${GREEN}3.${NC}  ${YELLOW}🕐 Таймзона${NC}               — timedatectl"
    echo -e "  ${GREEN}4.${NC}  ${YELLOW}🏷️  Изменить hostname${NC}       — имя сервера"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🧱 ФАЕРВОЛ И СЕТЬ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}5.${NC}  ${YELLOW}🔥 UFW: быстрая настройка${NC}  — включить UFW + порты 22, 443"
    echo -e "  ${GREEN}6.${NC}  ${YELLOW}🧱 UFW: свои порты${NC}         — открыть дополнительные порты"
    echo -e "  ${GREEN}7.${NC}  ${YELLOW}📋 UFW: статус${NC}             — показать правила"
    echo -e "  ${GREEN}8.${NC}  ${YELLOW}🚫 Отключить IPv6${NC}          — через sysctl"
    echo -e "  ${GREEN}9.${NC}  ${YELLOW}🚀 Включить BBR${NC}            — TCP congestion control"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🔐 БЕЗОПАСНОСТЬ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}10.${NC} ${YELLOW}🔐 SSH безопасность${NC}        — отключить пароль/root"
    echo -e "  ${GREEN}11.${NC} ${YELLOW}🛡️  fail2ban + auto-updates${NC} — защита от брутфорса"
    echo -e "  ${GREEN}12.${NC} ${YELLOW}👤 Создать пользователя${NC}    — sudo + SSH ключ"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  📦 ДОПОЛНИТЕЛЬНО${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}13.${NC} ${YELLOW}💾 Создать Swap${NC}            — swapfile"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}0.${NC}  ${WHITE}Назад${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}Выберите пункт: ${NC}"
}

# ============================================
# ПРОГРАММЫ
# ============================================
show_programs_menu() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🔧 УТИЛИТЫ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🛡️  TBLOCKER — блокировщик торрентов${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} ${YELLOW}🛡️  Установить TBlocker${NC}"
    echo -e "  ${GREEN}2.${NC} ${YELLOW}📝 Настройки TBlocker${NC}"
    echo -e "  ${GREEN}3.${NC} ${YELLOW}❌ Удалить TBlocker${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🚀 ZAPRET — обход DPI блокировок${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}4.${NC} ${YELLOW}🚀 Установить Zapret${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}0.${NC} ${WHITE}Назад${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}Выберите пункт: ${NC}"
}

# ============================================
# ФУНКЦИИ: ПОЛЕЗНЫЕ КОМАНДЫ
# ============================================

# Обновить систему
update_system() {
    show_header
    echo -e "${YELLOW}⚡ Обновление системы...${NC}"
    echo ""
    echo -e "${BLUE}Команда: apt update && apt upgrade -y && apt autoremove -y && apt autoclean${NC}"
    echo ""
    apt update && apt upgrade -y && apt autoremove -y && apt autoclean
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Тест на локацию
test_location() {
    show_header
    echo -e "${YELLOW}🌍 Тест на локацию...${NC}"
    echo ""
    echo -e "${BLUE}Команда: wget -qO- https://raw.githubusercontent.com/vernette/ipregion/master/ipregion.sh | bash${NC}"
    echo ""
    wget -qO- "https://raw.githubusercontent.com/vernette/ipregion/refs/heads/master/ipregion.sh" | bash
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Проверка блокировок
check_blocks() {
    show_header
    echo -e "${YELLOW}🚫 Проверка IP на блокировки...${NC}"
    echo ""
    echo -e "${BLUE}Команда: bash <(curl -Ls IP.Check.Place) -l en${NC}"
    echo ""
    bash <(curl -Ls IP.Check.Place) -l en
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Скорость к РФ
test_speed_ru() {
    show_header
    echo -e "${YELLOW}🏠 Проверка скорости к провайдерам РФ...${NC}"
    echo ""
    echo -e "${BLUE}Команда: wget -qO- bench.tlab.pw | bash${NC}"
    echo ""
    wget -qO- bench.tlab.pw | bash
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Скорость к зарубежным
test_speed_intl() {
    show_header
    echo -e "${YELLOW}🚀 Проверка скорости к зарубежным провайдерам...${NC}"
    echo ""
    echo -e "${BLUE}Команда: wget -qO- bench.sh | bash${NC}"
    echo ""
    wget -qO- bench.sh | bash
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Проверка Instagram
check_instagram() {
    show_header
    echo -e "${YELLOW}📱 Проверка блокировки Instagram/аудио...${NC}"
    echo ""
    echo -e "${BLUE}Команда: bash <(curl -Ls https://bench.openode.xyz/checker_inst.sh)${NC}"
    echo ""
    bash <(curl -L -s https://bench.openode.xyz/checker_inst.sh)
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# Проверка медиа-сервисов
check_media_services() {
    show_header
    echo -e "${YELLOW}📺 Проверка доступности медиа-сервисов...${NC}"
    echo ""
    echo -e "${BLUE}Команда: bash <(curl -sL https://raw.githubusercontent.com/jomertix/server-scripts/master/checkers/service_availability.sh)${NC}"
    echo ""
    bash <(curl -sL https://raw.githubusercontent.com/jomertix/server-scripts/refs/heads/master/checkers/service_availability.sh)
    echo ""
    echo -e "${GREEN}✅ Готово!${NC}"
    read -p "Нажмите Enter для продолжения..."
}

# YABS тест сервера
run_yabs() {
    show_header
    echo -e "${YELLOW}🖥️  YABS — комплексный тест сервера${NC}"
    echo ""
    echo -e "${CYAN}Тест включает:${NC}"
    echo -e "  • CPU benchmark (Geekbench)"
    echo -e "  • Тест скорости диска (fio)"
    echo -e "  • Тест скорости сети (iperf3)"
    echo ""
    echo -e "${RED}⚠️  Внимание: тест может занять 10-15 минут!${NC}"
    echo ""
    echo -e "${BLUE}Команда: bash <(curl -sL yabs.sh) -4${NC}"
    echo ""
    echo -ne "${CYAN}Запустить тест? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        bash <(curl -sL yabs.sh) -4
        echo ""
        echo -e "${GREEN}✅ Тест завершен!${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Сводка системы
system_summary() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  📊 СВОДКА СИСТЕМЫ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Uptime:${NC} $(uptime -p 2>/dev/null || uptime)"
    echo ""
    echo -e "${CYAN}Диск (/):${NC}"
    df -h / 2>/dev/null
    echo ""
    echo -e "${CYAN}Память:${NC}"
    free -h 2>/dev/null
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Сеть и порты
network_ports() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🌐 СЕТЬ И ПОРТЫ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}IP адреса:${NC}"
    ip -br a 2>/dev/null || hostname -I 2>/dev/null
    echo ""
    echo -e "${CYAN}Слушающие порты:${NC}"
    ss -tulpn 2>/dev/null | head -20 || netstat -tulpn 2>/dev/null | head -20
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Docker статус
docker_status() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🐳 DOCKER СТАТУС${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    if command -v docker &> /dev/null; then
        echo -e "${CYAN}Версия:${NC} $(docker --version 2>/dev/null)"
        echo ""
        echo -e "${CYAN}Контейнеры:${NC}"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -20
    else
        echo -e "${RED}Docker не установлен${NC}"
    fi
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Логи
show_logs() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  📝 ЛОГИ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Ошибки за 30 минут"
    echo -e "  ${GREEN}2.${NC} Логи Docker (100 строк)"
    echo -e "  ${GREEN}3.${NC} Логи по имени сервиса"
    echo -e "  ${GREEN}0.${NC} Назад"
    echo ""
    echo -ne "${CYAN}Выберите: ${NC}"
    read -r choice
    case $choice in
        1)
            journalctl --since "30 minutes ago" --priority=err --no-pager 2>/dev/null
            read -p "Нажмите Enter для продолжения..."
            ;;
        2)
            journalctl -u docker -n 100 --no-pager 2>/dev/null
            read -p "Нажмите Enter для продолжения..."
            ;;
        3)
            echo -ne "${CYAN}Введите имя сервиса: ${NC}"
            read -r unit
            journalctl -u "$unit" -n 100 --no-pager 2>/dev/null
            read -p "Нажмите Enter для продолжения..."
            ;;
    esac
}

# Статус системы (краткий)
system_status() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  📊 СТАТУС СИСТЕМЫ${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Uptime:${NC} $(uptime -p 2>/dev/null || uptime)"
    echo ""
    echo -e "${CYAN}Диск:${NC}"
    df -h / 2>/dev/null
    echo ""
    echo -e "${CYAN}Память:${NC}"
    free -h 2>/dev/null
    echo ""
    if command -v docker &> /dev/null; then
        echo -e "${CYAN}Docker контейнеры:${NC}"
        docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null | head -10
    fi
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# ============================================
# ФУНКЦИИ: НАСТРОЙКА СЕРВЕРА
# ============================================

# ============================================
# БЫСТРАЯ НАСТРОЙКА НОДЫ
# ============================================
quick_node_setup() {
    show_header
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ⚡ БЫСТРАЯ НАСТРОЙКА НОДЫ${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Текущие параметры:${NC}"
    echo -e "  Hostname: ${GREEN}$(hostname)${NC}"
    echo -e "  IPv6: $(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null | grep -q 1 && echo -e "${GREEN}отключен${NC}" || echo -e "${YELLOW}включен${NC}")"
    echo -e "  BBR: $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)"
    echo -e "  UFW: $(ufw status 2>/dev/null | head -1)"
    echo ""
    
    echo -e "${CYAN}Эта команда выполнит:${NC}"
    echo -e "  1. Отключит IPv6"
    echo -e "  2. Включит BBR"
    echo -e "  3. Настроит UFW (22, 443 + порт для панели)"
    echo -e "  4. Изменит hostname"
    echo ""
    
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Запрашиваем данные
    echo -ne "${CYAN}Новый hostname (Enter = оставить текущий): ${NC}"
    read -r new_hostname
    new_hostname="${new_hostname:-$(hostname)}"
    
    echo -ne "${CYAN}Порт для связи с панелью (Enter = пропустить): ${NC}"
    read -r panel_port
    
    echo -ne "${CYAN}IP панели для UFW (Enter = пропустить): ${NC}"
    read -r panel_ip
    
    echo ""
    echo -e "${YELLOW}Будет выполнено:${NC}"
    echo -e "  • Hostname: ${GREEN}$new_hostname${NC}"
    echo -e "  • IPv6: ${GREEN}отключить${NC}"
    echo -e "  • BBR: ${GREEN}включить${NC}"
    echo -e "  • UFW: ${GREEN}22/tcp, 443/tcp${NC}"
    [[ -n "$panel_port" ]] && echo -e "  • Порт панели: ${GREEN}$panel_port/tcp${NC}"
    [[ -n "$panel_ip" ]] && echo -e "  • IP панели: ${GREEN}$panel_ip${NC}"
    echo ""
    
    echo -ne "${CYAN}Применить? [y/N]: ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Отменено${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo ""
    
    # 1. Hostname
    echo -e "${BLUE}[1/4]${NC} Изменение hostname..."
    hostnamectl set-hostname "$new_hostname" 2>/dev/null
    # Обновляем /etc/hosts
    if ! grep -q "$new_hostname" /etc/hosts; then
        sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts 2>/dev/null
        grep -q "127.0.1.1" /etc/hosts || echo "127.0.1.1	$new_hostname" >> /etc/hosts
    fi
    echo -e "${GREEN}✓ Hostname: $new_hostname${NC}"
    
    # 2. IPv6 off
    echo -e "${BLUE}[2/4]${NC} Отключение IPv6..."
    cat > /etc/sysctl.d/99-disable-ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
    sysctl --system >/dev/null 2>&1
    echo -e "${GREEN}✓ IPv6 отключен${NC}"
    
    # 3. BBR
    echo -e "${BLUE}[3/4]${NC} Включение BBR..."
    if modprobe tcp_bbr 2>/dev/null; then
        cat > /etc/sysctl.d/99-bbr.conf << 'EOF'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
        sysctl --system >/dev/null 2>&1
        echo -e "${GREEN}✓ BBR включен${NC}"
    else
        echo -e "${YELLOW}⚠ BBR недоступен (нужно ядро 4.9+)${NC}"
    fi
    
    # 4. UFW
    echo -e "${BLUE}[4/4]${NC} Настройка UFW..."
    
    # Устанавливаем UFW если нет
    if ! command -v ufw &> /dev/null; then
        apt update -qq && apt install -y ufw >/dev/null 2>&1
    fi
    
    # Отключаем IPv6 в UFW
    sed -i 's/^IPV6=yes/IPV6=no/' /etc/default/ufw 2>/dev/null
    
    ufw --force reset >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    ufw allow 22/tcp comment 'SSH' >/dev/null 2>&1
    ufw allow 443/tcp comment 'HTTPS' >/dev/null 2>&1
    
    # Порт панели
    if [[ -n "$panel_port" && "$panel_port" =~ ^[0-9]+$ ]]; then
        if [[ -n "$panel_ip" ]]; then
            ufw allow from "$panel_ip" to any port "$panel_port" proto tcp comment 'Panel' >/dev/null 2>&1
            echo -e "${GREEN}✓ Порт $panel_port открыт только для $panel_ip${NC}"
        else
            ufw allow "$panel_port"/tcp comment 'Panel' >/dev/null 2>&1
            echo -e "${GREEN}✓ Порт $panel_port открыт${NC}"
        fi
    fi
    
    ufw --force enable >/dev/null 2>&1
    echo -e "${GREEN}✓ UFW настроен и включен${NC}"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ БЫСТРАЯ НАСТРОЙКА ЗАВЕРШЕНА${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Итого:${NC}"
    echo -e "  Hostname: $(hostname)"
    echo -e "  IPv6: отключен"
    echo -e "  BBR: $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)"
    echo ""
    echo -e "${CYAN}UFW правила:${NC}"
    ufw status numbered 2>/dev/null
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Изменить hostname
change_hostname() {
    show_header
    echo -e "${YELLOW}🏷️ Изменение hostname${NC}"
    echo ""
    echo -e "${CYAN}Текущий hostname:${NC} $(hostname)"
    echo ""
    echo -ne "${CYAN}Новый hostname: ${NC}"
    read -r new_hostname
    
    if [[ -z "$new_hostname" ]]; then
        echo -e "${YELLOW}Отменено${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    # Проверка на валидность
    if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        echo -e "${RED}Некорректный hostname. Используйте буквы, цифры и дефис.${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -ne "${CYAN}Установить hostname '$new_hostname'? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Устанавливаем hostname
        hostnamectl set-hostname "$new_hostname" 2>/dev/null
        
        # Обновляем /etc/hosts
        if grep -q "127.0.1.1" /etc/hosts; then
            sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts
        else
            echo "127.0.1.1	$new_hostname" >> /etc/hosts
        fi
        
        echo -e "${GREEN}✅ Hostname изменен на: $new_hostname${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Базовые пакеты
install_packages() {
    show_header
    echo -e "${YELLOW}📦 Установка базовых пакетов...${NC}"
    echo ""
    echo -e "${BLUE}Пакеты: curl, ca-certificates, gnupg, git, jq, unzip, htop, nano, net-tools${NC}"
    echo ""
    echo -ne "${CYAN}Установить? [y/N]: ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        apt update && apt install -y curl ca-certificates gnupg lsb-release git jq unzip htop nano iproute2 net-tools
        echo ""
        echo -e "${GREEN}✅ Готово!${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Таймзона
set_timezone() {
    show_header
    echo -e "${YELLOW}🕐 Настройка таймзоны${NC}"
    echo ""
    echo -e "${CYAN}Текущая:${NC} $(timedatectl show -p Timezone --value 2>/dev/null || echo 'неизвестно')"
    echo ""
    echo -ne "${CYAN}Введите таймзону (например UTC, Europe/Moscow): ${NC}"
    read -r tz
    if [[ -n "$tz" ]]; then
        timedatectl set-timezone "$tz"
        echo -e "${GREEN}✅ Таймзона установлена: $tz${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# UFW: быстрая настройка (22 + 443)
setup_ufw_quick() {
    show_header
    echo -e "${YELLOW}🔥 UFW: быстрая настройка${NC}"
    echo ""
    
    if ! command -v ufw &> /dev/null; then
        echo -e "${RED}UFW не установлен. Устанавливаем...${NC}"
        apt update && apt install -y ufw
    fi
    
    echo -e "${CYAN}Будет выполнено:${NC}"
    echo -e "  • Сброс правил UFW"
    echo -e "  • Запретить все входящие"
    echo -e "  • Разрешить все исходящие"
    echo -e "  • Открыть порт ${GREEN}22${NC} (SSH)"
    echo -e "  • Открыть порт ${GREEN}443${NC} (HTTPS)"
    echo -e "  • Включить UFW"
    echo ""
    echo -ne "${CYAN}Применить? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}Применяем...${NC}"
        # Отключаем IPv6 в UFW
        sed -i 's/^IPV6=yes/IPV6=no/' /etc/default/ufw 2>/dev/null
        ufw --force reset
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow 22/tcp comment 'SSH'
        ufw allow 443/tcp comment 'HTTPS'
        ufw --force enable
        echo ""
        echo -e "${GREEN}✅ UFW настроен!${NC}"
        echo ""
        ufw status numbered
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# UFW: свои порты
setup_ufw_custom() {
    show_header
    echo -e "${YELLOW}🧱 UFW: открыть свои порты${NC}"
    echo ""
    
    if ! command -v ufw &> /dev/null; then
        echo -e "${RED}UFW не установлен${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -e "${CYAN}Текущие правила:${NC}"
    ufw status numbered 2>/dev/null || echo "UFW не активен"
    echo ""
    
    echo -e "  ${GREEN}1.${NC} Открыть порт (TCP)"
    echo -e "  ${GREEN}2.${NC} Открыть порт (UDP)"
    echo -e "  ${GREEN}3.${NC} Открыть порт (TCP+UDP)"
    echo -e "  ${GREEN}4.${NC} Удалить правило по номеру"
    echo -e "  ${GREEN}0.${NC} Назад"
    echo ""
    echo -ne "${CYAN}Выберите: ${NC}"
    read -r choice
    
    case $choice in
        1)
            echo -ne "${CYAN}Введите порт (например 8080): ${NC}"
            read -r port
            if [[ "$port" =~ ^[0-9]+$ ]]; then
                ufw allow "$port"/tcp
                echo -e "${GREEN}✅ Порт $port/tcp открыт${NC}"
            fi
            ;;
        2)
            echo -ne "${CYAN}Введите порт: ${NC}"
            read -r port
            if [[ "$port" =~ ^[0-9]+$ ]]; then
                ufw allow "$port"/udp
                echo -e "${GREEN}✅ Порт $port/udp открыт${NC}"
            fi
            ;;
        3)
            echo -ne "${CYAN}Введите порт: ${NC}"
            read -r port
            if [[ "$port" =~ ^[0-9]+$ ]]; then
                ufw allow "$port"
                echo -e "${GREEN}✅ Порт $port открыт${NC}"
            fi
            ;;
        4)
            echo -ne "${CYAN}Номер правила для удаления: ${NC}"
            read -r num
            if [[ "$num" =~ ^[0-9]+$ ]]; then
                ufw --force delete "$num"
                echo -e "${GREEN}✅ Правило удалено${NC}"
            fi
            ;;
    esac
    read -p "Нажмите Enter для продолжения..."
}

# UFW: статус
show_ufw_status() {
    show_header
    echo -e "${YELLOW}📋 UFW: статус${NC}"
    echo ""
    
    if ! command -v ufw &> /dev/null; then
        echo -e "${RED}UFW не установлен${NC}"
    else
        echo -e "${CYAN}Статус:${NC}"
        ufw status verbose 2>/dev/null
        echo ""
        echo -e "${CYAN}Правила:${NC}"
        ufw status numbered 2>/dev/null
    fi
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Отключить IPv6
disable_ipv6() {
    show_header
    echo -e "${YELLOW}🚫 Отключение IPv6${NC}"
    echo ""
    
    local conf="/etc/sysctl.d/99-disable-ipv6.conf"
    
    # Проверяем текущий статус
    local ipv6_status=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)
    if [[ "$ipv6_status" == "1" ]]; then
        echo -e "${GREEN}IPv6 уже отключен${NC}"
        echo ""
        echo -ne "${CYAN}Включить обратно? [y/N]: ${NC}"
        read -r enable
        if [[ "$enable" =~ ^[Yy]$ ]]; then
            rm -f "$conf"
            sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
            sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
            sysctl -w net.ipv6.conf.lo.disable_ipv6=0 >/dev/null 2>&1
            echo -e "${GREEN}✅ IPv6 включен${NC}"
        fi
    else
        echo -e "${CYAN}IPv6 сейчас: ${GREEN}включен${NC}"
        echo ""
        echo -ne "${CYAN}Отключить IPv6? [y/N]: ${NC}"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            cat > "$conf" << 'EOF'
# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
            sysctl --system >/dev/null 2>&1
            echo -e "${GREEN}✅ IPv6 отключен${NC}"
        else
            echo -e "${YELLOW}Отменено${NC}"
        fi
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Включить BBR
enable_bbr() {
    show_header
    echo -e "${YELLOW}🚀 TCP BBR (Bottleneck Bandwidth and RTT)${NC}"
    echo ""
    
    # Проверяем текущий статус
    local current_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    local bbr_available=$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null)
    
    echo -e "${CYAN}Текущий алгоритм:${NC} $current_cc"
    echo -e "${CYAN}Доступные:${NC} $bbr_available"
    echo ""
    
    if [[ "$current_cc" == "bbr" ]]; then
        echo -e "${GREEN}BBR уже включен!${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -e "${CYAN}BBR улучшает:${NC}"
    echo -e "  • Скорость передачи данных"
    echo -e "  • Стабильность соединений"
    echo -e "  • Работу при потерях пакетов"
    echo ""
    echo -ne "${CYAN}Включить BBR? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local conf="/etc/sysctl.d/99-bbr.conf"
        
        # Проверяем что модуль доступен
        if ! modprobe tcp_bbr 2>/dev/null; then
            echo -e "${RED}Модуль tcp_bbr недоступен. Нужно ядро 4.9+${NC}"
            read -p "Нажмите Enter для продолжения..."
            return
        fi
        
        cat > "$conf" << 'EOF'
# TCP BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
        
        sysctl --system >/dev/null 2>&1
        
        # Проверяем результат
        local new_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
        if [[ "$new_cc" == "bbr" ]]; then
            echo -e "${GREEN}✅ BBR успешно включен!${NC}"
        else
            echo -e "${RED}❌ Не удалось включить BBR${NC}"
        fi
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# SSH безопасность
setup_ssh() {
    show_header
    echo -e "${YELLOW}🔐 Настройка SSH безопасности${NC}"
    echo ""
    echo -e "${RED}⚠️  Внимание: если отключить пароль без SSH ключа — потеряете доступ!${NC}"
    echo ""
    
    echo -ne "${CYAN}Отключить вход по паролю? [y/N]: ${NC}"
    read -r disable_pass
    
    echo -ne "${CYAN}Запретить root логин? [y/N]: ${NC}"
    read -r disable_root
    
    echo -ne "${CYAN}Новый SSH порт (пусто = не менять): ${NC}"
    read -r new_port
    
    local cfg="/etc/ssh/sshd_config"
    cp -a "$cfg" "${cfg}.backup.$(date +%Y%m%d-%H%M%S)"
    
    if [[ "$disable_pass" =~ ^[Yy]$ ]]; then
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$cfg"
        grep -q "^PasswordAuthentication" "$cfg" || echo "PasswordAuthentication no" >> "$cfg"
    fi
    
    if [[ "$disable_root" =~ ^[Yy]$ ]]; then
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$cfg"
        grep -q "^PermitRootLogin" "$cfg" || echo "PermitRootLogin no" >> "$cfg"
    fi
    
    if [[ -n "$new_port" && "$new_port" =~ ^[0-9]+$ ]]; then
        sed -i "s/^#*Port.*/Port $new_port/" "$cfg"
        grep -q "^Port" "$cfg" || echo "Port $new_port" >> "$cfg"
    fi
    
    if sshd -t 2>/dev/null; then
        systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null
        echo -e "${GREEN}✅ SSH настроен!${NC}"
    else
        echo -e "${RED}❌ Ошибка в конфиге, откат...${NC}"
        cp -a "${cfg}.backup."* "$cfg" 2>/dev/null
    fi
    read -p "Нажмите Enter для продолжения..."
}


# Swap
setup_swap() {
    show_header
    echo -e "${YELLOW}💾 Настройка Swap${NC}"
    echo ""
    
    if swapon --show 2>/dev/null | grep -q .; then
        echo -e "${GREEN}Swap уже включен:${NC}"
        swapon --show
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -ne "${CYAN}Размер swap в ГБ (1, 2, 4...): ${NC}"
    read -r size
    
    if [[ "$size" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}Создаём /swapfile ${size}G...${NC}"
        fallocate -l "${size}G" /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=$((size*1024)) status=progress
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}✅ Swap создан!${NC}"
        swapon --show
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Безопасность
setup_security() {
    show_header
    echo -e "${YELLOW}🛡️ Установка fail2ban и auto-updates${NC}"
    echo ""
    echo -ne "${CYAN}Установить fail2ban и unattended-upgrades? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        apt update && apt install -y fail2ban unattended-upgrades
        systemctl enable --now fail2ban 2>/dev/null
        dpkg-reconfigure -f noninteractive unattended-upgrades 2>/dev/null
        echo -e "${GREEN}✅ Готово!${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Создать пользователя
create_user() {
    show_header
    echo -e "${YELLOW}👤 Создание пользователя${NC}"
    echo ""
    echo -ne "${CYAN}Имя пользователя: ${NC}"
    read -r username
    
    if [[ -z "$username" ]]; then
        echo -e "${YELLOW}Отменено${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    if ! id "$username" &>/dev/null; then
        useradd -m -s /bin/bash "$username"
        echo -e "${GREEN}Пользователь $username создан${NC}"
    else
        echo -e "${YELLOW}Пользователь уже существует${NC}"
    fi
    
    echo -ne "${CYAN}Добавить в sudo? [Y/n]: ${NC}"
    read -r add_sudo
    if [[ ! "$add_sudo" =~ ^[Nn]$ ]]; then
        usermod -aG sudo "$username"
        echo -e "${GREEN}Добавлен в sudo${NC}"
    fi
    
    echo -ne "${CYAN}SSH публичный ключ (пусто = пропустить): ${NC}"
    read -r pubkey
    if [[ -n "$pubkey" ]]; then
        local home_dir
        home_dir=$(getent passwd "$username" | cut -d: -f6)
        mkdir -p "$home_dir/.ssh"
        chmod 700 "$home_dir/.ssh"
        echo "$pubkey" >> "$home_dir/.ssh/authorized_keys"
        chmod 600 "$home_dir/.ssh/authorized_keys"
        chown -R "$username:$username" "$home_dir/.ssh"
        echo -e "${GREEN}SSH ключ добавлен${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# ============================================
# ЦИКЛЫ МЕНЮ
# ============================================

# Цикл полезных команд
useful_loop() {
    while true; do
        show_useful_menu
        read -r choice
        case $choice in
            1) update_system ;;
            2) test_location ;;
            3) check_blocks ;;
            4) test_speed_ru ;;
            5) test_speed_intl ;;
            6) check_instagram ;;
            7) check_media_services ;;
            8) run_yabs ;;
            9) network_ports ;;
            10) docker_status ;;
            0) return ;;
            *) echo -e "${RED}Неверный выбор${NC}"; sleep 1 ;;
        esac
    done
}

# Установить TBlocker для Remnawave/Remnanode
install_tblocker() {
    show_header
    echo -e "${YELLOW}🛡️ Установка TBlocker для Remnawave${NC}"
    echo ""
    
    # Проверяем наличие RemnaNode
    if [[ ! -d "/opt/remnanode" ]]; then
        echo -e "${RED}❌ RemnaNode не найден в /opt/remnanode${NC}"
        echo ""
        echo -e "${YELLOW}TBlocker требует установленный RemnaNode.${NC}"
        echo -e "${CYAN}Сначала установите RemnaNode, затем запустите установку TBlocker.${NC}"
        echo ""
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -e "${GREEN}✓ RemnaNode найден${NC}"
    echo ""
    
    echo -e "${CYAN}TBlocker — блокировщик торрентов для Remnawave${NC}"
    echo -e "${GRAY}GitHub: github.com/kutovoys/xray-torrent-blocker${NC}"
    echo ""
    echo -e "${YELLOW}Скрипт автоматически:${NC}"
    echo -e "  • Создаст папку для логов"
    echo -e "  • Добавит volume в docker-compose.yml"
    echo -e "  • Перезапустит RemnaNode"
    echo -e "  • Установит и запустит TBlocker"
    echo ""
    echo -ne "${CYAN}Установить TBlocker? [y/N]: ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Отменено${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo ""
    
    # Пробуем локальный скрипт, иначе скачиваем с GitHub
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
    if [[ -f "${SCRIPT_DIR}/install-tblocker.sh" ]]; then
        bash "${SCRIPT_DIR}/install-tblocker.sh"
    else
        echo -e "${YELLOW}Скачиваем установщик...${NC}"
        curl -fsSL https://raw.githubusercontent.com/Spakieone/SpakieWW/main/install-tblocker.sh -o /tmp/install-tblocker.sh
        if [[ -f /tmp/install-tblocker.sh ]]; then
            bash /tmp/install-tblocker.sh
            rm -f /tmp/install-tblocker.sh
        else
            echo -e "${RED}❌ Не удалось скачать установщик${NC}"
        fi
    fi
    
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Настройки TBlocker
manage_tblocker() {
    while true; do
        show_header
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  📝 НАСТРОЙКИ TBLOCKER${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        # Проверяем установлен ли TBlocker
        if [[ ! -f /opt/tblocker/config.yaml ]]; then
            echo -e "${RED}TBlocker не установлен${NC}"
            echo ""
            read -p "Нажмите Enter для продолжения..."
            return
        fi
        
        # Показываем статус
        echo -e "${CYAN}Статус сервиса:${NC}"
        if systemctl is-active --quiet tblocker 2>/dev/null; then
            echo -e "  ${GREEN}● Работает${NC}"
        else
            echo -e "  ${RED}● Остановлен${NC}"
        fi
        echo ""
        
        # Показываем текущий конфиг
        echo -e "${CYAN}Текущие настройки:${NC}"
        if [[ -f /opt/tblocker/config.yaml ]]; then
            grep -E "^(BlockDuration|WebhookURL|LogFile):" /opt/tblocker/config.yaml 2>/dev/null | while read line; do
                echo -e "  ${GRAY}$line${NC}"
            done
        fi
        echo ""
        
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  ${GREEN}1.${NC} ${YELLOW}📝 Редактировать конфиг${NC}    — nano /opt/tblocker/config.yaml"
        echo -e "  ${GREEN}2.${NC} ${YELLOW}🔄 Перезапустить${NC}           — systemctl restart tblocker"
        echo -e "  ${GREEN}3.${NC} ${YELLOW}⏹️  Остановить${NC}              — systemctl stop tblocker"
        echo -e "  ${GREEN}4.${NC} ${YELLOW}▶️  Запустить${NC}               — systemctl start tblocker"
        echo -e "  ${GREEN}5.${NC} ${YELLOW}📋 Показать логи${NC}           — journalctl -u tblocker"
        echo -e "  ${GREEN}6.${NC} ${YELLOW}📊 Полный статус${NC}           — systemctl status tblocker"
        echo -e "  ${GREEN}0.${NC} ${WHITE}Назад${NC}"
        echo ""
        echo -ne "${CYAN}Выберите: ${NC}"
        read -r choice
        
        case $choice in
            1)
                nano /opt/tblocker/config.yaml
                echo ""
                echo -ne "${CYAN}Перезапустить TBlocker для применения изменений? [y/N]: ${NC}"
                read -r restart
                if [[ "$restart" =~ ^[Yy]$ ]]; then
                    systemctl restart tblocker
                    echo -e "${GREEN}✅ TBlocker перезапущен${NC}"
                fi
                sleep 2
                ;;
            2)
                systemctl restart tblocker
                echo -e "${GREEN}✅ TBlocker перезапущен${NC}"
                sleep 2
                ;;
            3)
                systemctl stop tblocker
                echo -e "${YELLOW}TBlocker остановлен${NC}"
                sleep 2
                ;;
            4)
                systemctl start tblocker
                echo -e "${GREEN}✅ TBlocker запущен${NC}"
                sleep 2
                ;;
            5)
                journalctl -u tblocker -n 50 --no-pager
                read -p "Нажмите Enter для продолжения..."
                ;;
            6)
                systemctl status tblocker --no-pager
                read -p "Нажмите Enter для продолжения..."
                ;;
            0)
                return
                ;;
        esac
    done
}

# Удалить TBlocker
remove_tblocker() {
    show_header
    echo -e "${YELLOW}❌ Удаление TBlocker${NC}"
    echo ""
    
    # Проверяем, установлен ли
    if ! systemctl list-unit-files | grep -q tblocker && [[ ! -d /opt/tblocker ]]; then
        echo -e "${YELLOW}TBlocker не установлен${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo -e "${RED}⚠️  Внимание: будет удалено:${NC}"
    echo -e "  • Сервис tblocker"
    echo -e "  • Папка /opt/tblocker"
    echo -e "  • Все правила iptables от TBlocker"
    echo ""
    echo -ne "${CYAN}Удалить TBlocker? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}Удаляем...${NC}"
        
        # Останавливаем сервис
        if systemctl is-active --quiet tblocker 2>/dev/null; then
            echo -e "  Остановка сервиса..."
            systemctl stop tblocker 2>/dev/null
        fi
        
        # Отключаем сервис
        if systemctl is-enabled --quiet tblocker 2>/dev/null; then
            echo -e "  Отключение сервиса..."
            systemctl disable tblocker 2>/dev/null
        fi
        
        # Удаляем файл сервиса
        if [[ -f /etc/systemd/system/tblocker.service ]]; then
            echo -e "  Удаление файла сервиса..."
            rm -f /etc/systemd/system/tblocker.service
        fi
        
        # Перезагружаем systemd
        systemctl daemon-reload 2>/dev/null
        
        # Удаляем правила iptables от TBlocker
        echo -e "  Очистка правил iptables..."
        if iptables -L TBLOCKER_BLOCKED -n 2>/dev/null >/dev/null; then
            iptables -F TBLOCKER_BLOCKED 2>/dev/null
            iptables -X TBLOCKER_BLOCKED 2>/dev/null
        fi
        # Удаляем все правила с упоминанием tblocker
        iptables -S 2>/dev/null | grep -i tblocker | while read rule; do
            delete_rule=$(echo "$rule" | sed 's/-A /-D /')
            iptables $delete_rule 2>/dev/null
        done
        
        # Удаляем папку
        if [[ -d /opt/tblocker ]]; then
            echo -e "  Удаление /opt/tblocker..."
            rm -rf /opt/tblocker
        fi
        
        # Удаляем менеджер если есть
        if [[ -f /usr/local/bin/tblocker-manager ]]; then
            echo -e "  Удаление менеджера..."
            rm -f /usr/local/bin/tblocker-manager
        fi
        
        echo ""
        echo -e "${GREEN}✅ TBlocker полностью удалён!${NC}"
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    read -p "Нажмите Enter для продолжения..."
}

# Установить Zapret (обход DPI блокировок)
install_zapret() {
    show_header
    echo -e "${YELLOW}🚀 Zapret — обход DPI блокировок${NC}"
    echo -e "${GRAY}GitHub: github.com/IndeecFOX/zapret4rocket${NC}"
    echo ""
    
    # Проверяем, установлен ли уже
    if [[ -d /opt/zapret ]] || command -v z4r &>/dev/null; then
        echo -e "${GREEN}Zapret уже установлен${NC}"
        echo ""
        echo -e "${CYAN}Для управления используйте команду:${NC} ${WHITE}z4r${NC}"
        echo ""
        echo -ne "${CYAN}Открыть меню Zapret? [Y/n]: ${NC}"
        read -r open_menu
        if [[ ! "$open_menu" =~ ^[Nn]$ ]]; then
            z4r
        fi
        return
    fi
    
    echo -e "${CYAN}Zapret — инструмент для обхода блокировок DPI${NC}"
    echo ""
    echo -e "${YELLOW}Возможности:${NC}"
    echo -e "  • Обход замедления YouTube"
    echo -e "  • Разблокировка Discord, Telegram, WhatsApp"
    echo -e "  • Доступ к заблокированным сайтам"
    echo -e "  • Подбор стратегий под вашего провайдера"
    echo ""
    echo -e "${YELLOW}Поддерживаемые системы:${NC}"
    echo -e "  • Ubuntu 22/24, Debian 12"
    echo -e "  • OpenWRT, Keenetic (Entware)"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}Установить Zapret? [y/N]: ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}Запускаем установщик Zapret...${NC}"
        echo -e "${GRAY}(На все вопросы можно нажимать Enter для значений по умолчанию)${NC}"
        echo ""
        
        # Скачиваем и запускаем z4r
        curl -fsSL -O https://raw.githubusercontent.com/IndeecFOX/z4r/4/z4r && sh z4r
        
        echo ""
        
        # Проверяем успешность установки
        if [[ -d /opt/zapret ]] || command -v z4r &>/dev/null; then
            echo -e "${GREEN}✅ Zapret установлен!${NC}"
            echo ""
            echo -e "${CYAN}Для управления используйте команду:${NC} ${WHITE}z4r${NC}"
        else
            echo -e "${YELLOW}Установка завершена. Проверьте вывод выше.${NC}"
        fi
    else
        echo -e "${YELLOW}Отменено${NC}"
    fi
    
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# Цикл настройки сервера
server_loop() {
    while true; do
        show_server_menu
        read -r choice
        case $choice in
            1) quick_node_setup ;;
            2) install_packages ;;
            3) set_timezone ;;
            4) change_hostname ;;
            5) setup_ufw_quick ;;
            6) setup_ufw_custom ;;
            7) show_ufw_status ;;
            8) disable_ipv6 ;;
            9) enable_bbr ;;
            10) setup_ssh ;;
            11) setup_security ;;
            12) create_user ;;
            13) setup_swap ;;
            0) return ;;
            *) echo -e "${RED}Неверный выбор${NC}"; sleep 1 ;;
        esac
    done
}

# Цикл программ
programs_loop() {
    while true; do
        show_programs_menu
        read -r choice
        case $choice in
            1) install_tblocker ;;
            2) manage_tblocker ;;
            3) remove_tblocker ;;
            4) install_zapret ;;
            0) return ;;
            *) echo -e "${RED}Неверный выбор${NC}"; sleep 1 ;;
        esac
    done
}

# Установка Remna Panel/Node by Capybara
install_remna_capybara() {
    show_header
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  🚀 УСТАНОВКА REMNA PANEL/NODE${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Установщик от Capybara${NC}"
    echo -e "${GRAY}GitHub: github.com/Capybara-z/RemnaSetup${NC}"
    echo ""
    echo -e "${YELLOW}Этот скрипт установит:${NC}"
    echo -e "  • Remna Panel — панель управления"
    echo -e "  • Remna Node — нода для подключений"
    echo ""
    echo -ne "${CYAN}Запустить установщик? [y/N]: ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Отменено${NC}"
        read -p "Нажмите Enter для продолжения..."
        return
    fi
    
    echo ""
    bash <(curl -fsSL raw.githubusercontent.com/Capybara-z/RemnaSetup/refs/heads/main/install.sh)
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

# ============================================
# ГЛАВНЫЙ ЦИКЛ
# ============================================
while true; do
    show_main_menu
    read -r choice
    case $choice in
        1) useful_loop ;;
        2) server_loop ;;
        3) programs_loop ;;
        4) install_remna_capybara ;;
        0)
            echo ""
            echo -e "${GREEN}👋 До свидания!${NC}"
            echo ""
            exit 0
            ;;
        *) echo -e "${RED}Неверный выбор${NC}"; sleep 1 ;;
    esac
done
