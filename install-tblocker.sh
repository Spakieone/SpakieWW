#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции вывода
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Проверка root
if [[ $EUID -ne 0 ]]; then
   error "Этот скрипт должен быть запущен с правами root (sudo)"
   exit 1
fi

# Баннер
echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════╗
║   Tblocker Auto Installer for RemnaNode   ║
║              by SpakieWW                   ║
╚════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ========================================
# Настройка параметров
# ========================================
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Настройка параметров установки      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Режим блокировки по умолчанию
BLOCK_MODE="iptables"

# Домен бота для webhook
echo -e "${YELLOW}Настройка Webhook (опционально)${NC}"
echo "Введите домен бота для webhook (например: bot.example.com)"
echo "Оставьте пустым, если webhook не нужен"
read -p "Домен бота: " BOT_DOMAIN
if [[ -n "$BOT_DOMAIN" ]]; then
    SEND_WEBHOOK="true"
    WEBHOOK_URL="https://${BOT_DOMAIN}/tblocker/webhook"
    info "Webhook URL: $WEBHOOK_URL"
else
    SEND_WEBHOOK="false"
    WEBHOOK_URL=""
    info "Webhook отключен"
fi
echo ""

# Срок блокировки
read -p "Введите срок блокировки в минутах [по умолчанию: 30]: " BLOCK_DURATION
BLOCK_DURATION=${BLOCK_DURATION:-30}
if ! [[ "$BLOCK_DURATION" =~ ^[0-9]+$ ]]; then
    warning "Некорректное значение, установлено 30 минут"
    BLOCK_DURATION=30
fi
info "Срок блокировки: $BLOCK_DURATION минут"
echo ""

# Белый список IP по умолчанию
BYPASS_IPS='  - "127.0.0.1"
  - "::1"'

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Начинаем установку...${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

# ========================================
# Шаг 1: Проверка RemnaNode
# ========================================
echo -e "${BLUE}[1/10]${NC} Проверка RemnaNode..."

if [[ ! -d "/opt/remnanode" ]]; then
    error "Папка /opt/remnanode не найдена. Установите RemnaNode перед запуском этого скрипта."
    exit 1
fi
success "Папка RemnaNode найдена"

cd /opt/remnanode

if [[ ! -f "docker-compose.yml" ]]; then
    error "Файл docker-compose.yml не найден в /opt/remnanode"
    exit 1
fi
success "Файл docker-compose.yml найден"

# ========================================
# Шаг 2: Резервная копия docker-compose.yml
# ========================================
echo -e "${BLUE}[2/10]${NC} Резервная копия docker-compose.yml..."

cp docker-compose.yml docker-compose.yml.backup_$(date +%Y%m%d_%H%M%S)
success "Создана резервная копия docker-compose.yml"

# ========================================
# Шаг 3: Добавление volumes
# ========================================
echo -e "${BLUE}[3/10]${NC} Настройка volumes в docker-compose.yml..."

if grep -q "/var/log/remnanode" docker-compose.yml; then
    warning "Volumes уже настроены в docker-compose.yml"
else
    sed -i '/volumes:/a\      - /var/log/remnanode:/var/log/remnanode' docker-compose.yml 2>/dev/null
    if [[ $? -eq 0 ]]; then
        success "Volumes добавлены в docker-compose.yml"
    else
        warning "Не удалось добавить volumes автоматически"
    fi
fi

# ========================================
# Шаг 4: Создание папки для логов
# ========================================
echo -e "${BLUE}[4/10]${NC} Создание папки для логов..."

if [[ -d "/var/log/remnanode" ]]; then
    warning "Папка /var/log/remnanode уже существует"
else
    mkdir -p /var/log/remnanode
    success "Создана папка /var/log/remnanode"
fi

# ========================================
# Шаг 5: Установка logrotate
# ========================================
echo -e "${BLUE}[5/10]${NC} Настройка logrotate..."

apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq logrotate >/dev/null 2>&1

cat > /etc/logrotate.d/remnanode << 'EOF'
/var/log/remnanode/*.log {
    size 50M
    rotate 5
    compress
    missingok
    notifempty
    copytruncate
}
EOF

logrotate -f /etc/logrotate.d/remnanode >/dev/null 2>&1
success "Logrotate настроен"

# ========================================
# Шаг 6: Перезапуск RemnaNode
# ========================================
echo -e "${BLUE}[6/10]${NC} Перезапуск контейнера RemnaNode..."

docker compose down >/dev/null 2>&1 || docker-compose down >/dev/null 2>&1
docker compose up -d >/dev/null 2>&1 || docker-compose up -d >/dev/null 2>&1
success "Контейнер RemnaNode перезапущен"
sleep 3

# ========================================
# Шаг 7: Удаление старого Tblocker
# ========================================
echo -e "${BLUE}[7/10]${NC} Проверка старой версии Tblocker..."

if systemctl is-active --quiet tblocker 2>/dev/null; then
    warning "Найдена старая версия Tblocker, удаляем..."
    systemctl stop tblocker >/dev/null 2>&1
    systemctl disable tblocker >/dev/null 2>&1
fi

if [[ -d "/opt/tblocker" ]]; then
    rm -rf /opt/tblocker
    info "Старая папка /opt/tblocker удалена"
fi

info "Старая версия Tblocker не найдена"

# ========================================
# Шаг 8: Скачивание Tblocker
# ========================================
echo -e "${BLUE}[8/10]${NC} Установка Tblocker..."

# Определяем архитектуру
ARCH=$(uname -m)
case $ARCH in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    *) error "Архитектура $ARCH не поддерживается"; exit 1 ;;
esac

# Получаем последнюю версию
VERSION=$(curl -fsSL "https://api.github.com/repos/kutovoys/xray-torrent-blocker/releases/latest" 2>/dev/null | grep '"tag_name"' | cut -d'"' -f4)
VERSION=${VERSION:-v1.1.0}

info "Версия: ${VERSION}, Архитектура: ${ARCH}"

URL="https://github.com/kutovoys/xray-torrent-blocker/releases/download/${VERSION}/xray-torrent-blocker-${VERSION}-linux-${ARCH}.tar.gz"

mkdir -p /opt/tblocker

if ! curl -fsSL "$URL" -o /tmp/tblocker.tar.gz; then
    error "Ошибка скачивания Tblocker"
    exit 1
fi

tar -xzf /tmp/tblocker.tar.gz -C /opt/tblocker
rm -f /tmp/tblocker.tar.gz

if [[ ! -f "/opt/tblocker/tblocker" ]]; then
    error "Бинарник tblocker не найден после распаковки"
    exit 1
fi

chmod +x /opt/tblocker/tblocker
success "Tblocker установлен успешно"

# ========================================
# Шаг 9: Настройка конфигурации
# ========================================
echo -e "${BLUE}[9/10]${NC} Настройка конфигурации Tblocker..."

if [[ "$SEND_WEBHOOK" == "true" ]]; then
cat > /opt/tblocker/config.yaml << EOF
LogFile: "/var/log/remnanode/access.log"
BlockDuration: ${BLOCK_DURATION}
TorrentTag: "TORRENT"
BlockMode: "${BLOCK_MODE}"
BypassIPS:
${BYPASS_IPS}
StorageDir: "/opt/tblocker"
IgnoreEmail: false
SendWebhook: true
WebhookURL: "${WEBHOOK_URL}"
WebhookTemplate: '{"username":"%s","ip":"%s","server":"%s","action":"%s","duration":%d,"timestamp":"%s"}'
EOF
else
cat > /opt/tblocker/config.yaml << EOF
LogFile: "/var/log/remnanode/access.log"
BlockDuration: ${BLOCK_DURATION}
TorrentTag: "TORRENT"
BlockMode: "${BLOCK_MODE}"
BypassIPS:
${BYPASS_IPS}
StorageDir: "/opt/tblocker"
IgnoreEmail: false
SendWebhook: false
EOF
fi

success "Конфигурация Tblocker создана"

# ========================================
# Шаг 10: Настройка systemd сервиса
# ========================================
echo -e "${BLUE}[10/10]${NC} Настройка systemd сервиса..."

cat > /etc/systemd/system/tblocker.service << 'EOF'
[Unit]
Description=Xray Torrent Blocker
After=network.target

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

sleep 2

if systemctl is-active --quiet tblocker; then
    success "Сервис Tblocker запущен и работает"
else
    error "Сервис Tblocker не запустился"
    journalctl -u tblocker -n 5 --no-pager
    exit 1
fi

# ========================================
# Финальный вывод
# ========================================
echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}       ✓ Установка завершена успешно!       ${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

HOSTNAME=$(hostname)

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Информация о сервере             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Сервер:${NC} ${HOSTNAME}"
echo -e "${GREEN}Блокировка:${NC} ${BLOCK_DURATION} минут"
if [[ "$SEND_WEBHOOK" == "true" ]]; then
    echo -e "${GREEN}Webhook:${NC} ${WEBHOOK_URL}"
fi
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "  1. Перейдите в панель RemnaWave"
echo "  2. Откройте профили (конфиг xray)"
echo "  3. Измените секцию log:"
echo ""
echo -e "${BLUE}  \"log\": {${NC}"
echo -e "${BLUE}      \"error\": \"/var/log/remnanode/error.log\",${NC}"
echo -e "${BLUE}      \"access\": \"/var/log/remnanode/access.log\",${NC}"
echo -e "${BLUE}      \"loglevel\": \"warning\"${NC}"
echo -e "${BLUE}  }${NC}"
echo ""
echo "  4. В \"outbounds\" добавьте:"
echo ""
echo -e "${BLUE}  {${NC}"
echo -e "${BLUE}    \"tag\": \"TORRENT\",${NC}"
echo -e "${BLUE}    \"protocol\": \"blackhole\"${NC}"
echo -e "${BLUE}  }${NC}"
echo ""
echo "  5. В \"routing\" добавьте:"
echo ""
echo -e "${BLUE}  {${NC}"
echo -e "${BLUE}    \"type\": \"field\",${NC}"
echo -e "${BLUE}    \"protocol\": [\"bittorrent\"],${NC}"
echo -e "${BLUE}    \"outboundTag\": \"TORRENT\"${NC}"
echo -e "${BLUE}  }${NC}"
echo ""
echo "  6. Нажмите 'Форматировать' и 'Сохранить конфиг'"
echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Полезные команды:${NC}"
echo "  • Проверить статус: systemctl status tblocker"
echo "  • Просмотр логов: journalctl -u tblocker -f"
echo "  • Перезапуск: systemctl restart tblocker"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
