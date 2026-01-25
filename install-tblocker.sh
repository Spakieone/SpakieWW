#!/bin/bash
# TBlocker Installer для Remnawave/Remnanode
# GitHub: github.com/kutovoys/xray-torrent-blocker

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}        ${YELLOW}TBlocker Installer для Remnawave${NC}                       ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Проверяем root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Требуются права root${NC}"
    exit 1
fi

# Проверяем RemnaNode
if [[ ! -d "/opt/remnanode" ]]; then
    echo -e "${RED}❌ RemnaNode не найден в /opt/remnanode${NC}"
    exit 1
fi

# Проверяем, установлен ли уже
if systemctl is-active --quiet tblocker 2>/dev/null; then
    echo -e "${GREEN}TBlocker уже установлен и работает${NC}"
    systemctl status tblocker --no-pager | head -5
    echo ""
    echo -ne "${CYAN}Переустановить? [y/N]: ${NC}"
    read -r reinstall
    [[ ! "$reinstall" =~ ^[Yy]$ ]] && exit 0
    systemctl stop tblocker 2>/dev/null
fi

# ===== НАСТРОЙКИ =====
echo ""
echo -e "${YELLOW}Выберите файрвол:${NC}"
echo -e "  ${GREEN}1.${NC} iptables (рекомендуется)"
echo -e "  ${GREEN}2.${NC} nftables"
echo -ne "${CYAN}Выбор [1]: ${NC}"
read -r fw_choice

BLOCK_MODE="iptables"
[[ "$fw_choice" == "2" ]] && BLOCK_MODE="nft"

echo -ne "${CYAN}Время блокировки в минутах [10]: ${NC}"
read -r BLOCK_DURATION
BLOCK_DURATION=${BLOCK_DURATION:-10}
[[ ! "$BLOCK_DURATION" =~ ^[0-9]+$ ]] && BLOCK_DURATION=10

echo ""
echo -e "${YELLOW}Начинаем установку...${NC}"
echo ""

# [1] Зависимости
echo -e "  ${CYAN}[1/9]${NC} Установка зависимостей..."
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq conntrack curl jq >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓${NC} Зависимости"

# [2] Папка для логов
echo -e "  ${CYAN}[2/9]${NC} Создание папки логов..."
mkdir -p /var/log/remnanode
chmod 755 /var/log/remnanode
echo -e "  ${GREEN}✓${NC} /var/log/remnanode"

# [3] docker-compose.yml
echo -e "  ${CYAN}[3/9]${NC} Настройка docker-compose.yml..."
COMPOSE_FILE="/opt/remnanode/docker-compose.yml"
if [[ -f "$COMPOSE_FILE" ]]; then
    if ! grep -q "/var/log/remnanode" "$COMPOSE_FILE" 2>/dev/null; then
        cp "$COMPOSE_FILE" "${COMPOSE_FILE}.bak"
        if grep -q "volumes:" "$COMPOSE_FILE"; then
            sed -i '/volumes:/a\      - "/var/log/remnanode:/var/log/remnanode"' "$COMPOSE_FILE"
        fi
        echo -e "  ${GREEN}✓${NC} Volume добавлен"
    else
        echo -e "  ${GREEN}✓${NC} Volume уже есть"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} docker-compose.yml не найден"
fi

# [4] xray конфиг - логирование
echo -e "  ${CYAN}[4/9]${NC} Настройка логирования xray..."
XRAY_CONFIG=""
for cfg in "/opt/remnanode/xray_config.json" "/opt/remnanode/config.json" "/opt/remnanode/xray/config.json"; do
    [[ -f "$cfg" ]] && XRAY_CONFIG="$cfg" && break
done

if [[ -n "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
    if ! grep -q '"/var/log/remnanode/access.log"' "$XRAY_CONFIG" 2>/dev/null; then
        cp "$XRAY_CONFIG" "${XRAY_CONFIG}.bak"
        TMP=$(mktemp)
        jq '.log = {"access": "/var/log/remnanode/access.log", "error": "/var/log/remnanode/error.log", "loglevel": "warning"}' "$XRAY_CONFIG" > "$TMP" 2>/dev/null
        [[ -s "$TMP" ]] && mv "$TMP" "$XRAY_CONFIG" && echo -e "  ${GREEN}✓${NC} Логирование настроено" || echo -e "  ${YELLOW}⚠${NC} Ошибка настройки"
        rm -f "$TMP"
    else
        echo -e "  ${GREEN}✓${NC} Логирование уже настроено"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Конфиг не найден или нет jq"
fi

# [5] xray конфиг - routing TORRENT
echo -e "  ${CYAN}[5/9]${NC} Настройка routing для торрентов..."
if [[ -n "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
    if ! grep -q '"outboundTag".*"TORRENT"' "$XRAY_CONFIG" 2>/dev/null; then
        TMP=$(mktemp)
        jq '
            (if .routing then .routing.rules = (.routing.rules // []) + [{"type": "field", "protocol": ["bittorrent"], "outboundTag": "TORRENT"}]
            else . + {"routing": {"rules": [{"type": "field", "protocol": ["bittorrent"], "outboundTag": "TORRENT"}]}} end) |
            .outbounds = (.outbounds // []) + [{"protocol": "blackhole", "tag": "TORRENT"}]
        ' "$XRAY_CONFIG" > "$TMP" 2>/dev/null
        [[ -s "$TMP" ]] && mv "$TMP" "$XRAY_CONFIG" && echo -e "  ${GREEN}✓${NC} Routing настроен" || echo -e "  ${YELLOW}⚠${NC} Ошибка"
        rm -f "$TMP"
    else
        echo -e "  ${GREEN}✓${NC} Routing уже настроен"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Пропущено"
fi

# [6] Перезапуск RemnaNode
echo -e "  ${CYAN}[6/9]${NC} Перезапуск RemnaNode..."
if [[ -f "/opt/remnanode/docker-compose.yml" ]]; then
    cd /opt/remnanode
    docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} RemnaNode перезапущен"
    sleep 3
else
    echo -e "  ${YELLOW}⚠${NC} Перезапустите вручную"
fi

# [7] Скачивание TBlocker
echo -e "  ${CYAN}[7/9]${NC} Скачивание TBlocker..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm" ;;
    *) echo -e "${RED}Неподдерживаемая архитектура${NC}"; exit 1 ;;
esac

VERSION=$(curl -fsSL --connect-timeout 10 "https://api.github.com/repos/kutovoys/xray-torrent-blocker/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VERSION=${VERSION:-"v1.1.0"}

URL="https://github.com/kutovoys/xray-torrent-blocker/releases/download/${VERSION}/tblocker_${VERSION#v}_linux_${ARCH}.tar.gz"

mkdir -p /opt/tblocker
curl -fsSL "$URL" -o /tmp/tblocker.tar.gz || { echo -e "${RED}Ошибка скачивания${NC}"; exit 1; }
tar -xzf /tmp/tblocker.tar.gz -C /opt/tblocker 2>/dev/null
rm -f /tmp/tblocker.tar.gz
chmod +x /opt/tblocker/tblocker
echo -e "  ${GREEN}✓${NC} TBlocker ${VERSION}"

# [8] Конфиг TBlocker
echo -e "  ${CYAN}[8/9]${NC} Создание конфигурации..."
cat > /opt/tblocker/config.yaml << EOF
# TBlocker configuration for Remnawave
LogFile: "/var/log/remnanode/access.log"
BlockDuration: ${BLOCK_DURATION}
TorrentTag: "TORRENT"
BlockMode: "${BLOCK_MODE}"
BypassIPS:
  - "127.0.0.1"
  - "::1"
StorageDir: "/opt/tblocker"
IgnoreEmail: false
SendWebhook: false
EOF
echo -e "  ${GREEN}✓${NC} Конфиг создан"

# [9] Systemd сервис
echo -e "  ${CYAN}[9/9]${NC} Настройка сервиса..."
cat > /etc/systemd/system/tblocker.service << 'EOF'
[Unit]
Description=Xray Torrent Blocker
After=network.target docker.service

[Service]
Type=simple
WorkingDirectory=/opt/tblocker
ExecStart=/opt/tblocker/tblocker
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tblocker >/dev/null 2>&1
systemctl start tblocker
echo -e "  ${GREEN}✓${NC} Сервис запущен"

# Результат
echo ""
sleep 2
if systemctl is-active --quiet tblocker; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}           ${GREEN}✅ TBlocker успешно установлен!${NC}                     ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Конфиг:${NC}     /opt/tblocker/config.yaml"
    echo -e "${CYAN}Файрвол:${NC}    ${BLOCK_MODE}"
    echo -e "${CYAN}Блокировка:${NC} ${BLOCK_DURATION} мин"
    echo -e "${CYAN}Логи:${NC}       journalctl -u tblocker -f"
else
    echo -e "${RED}❌ Ошибка запуска${NC}"
    journalctl -u tblocker -n 10 --no-pager
fi
