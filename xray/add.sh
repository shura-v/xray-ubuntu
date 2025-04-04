#!/bin/bash

# Проверка, что xray установлен
CONFIG="/usr/local/etc/xray/config.json"
if [ ! -f "$CONFIG" ]; then
  echo "❌ Конфиг Xray не найден. Сначала запусти install-xray.sh"
  exit 1
fi

# Генерация UUID и имени
UUID=$(cat /proc/sys/kernel/random/uuid)
read -p "Имя клиента (например: alex-phone): " NAME

# Вставка клиента в JSON (через jq)
apt-get install -y jq >/dev/null 2>&1
TMP=$(mktemp)
jq ".inbounds[0].settings.clients += [{\"id\":\"$UUID\",\"alterId\":0,\"email\":\"$NAME\"}]" $CONFIG > "$TMP" && mv "$TMP" $CONFIG

# Перезапуск xray
systemctl restart xray

# IP для импорта
IP=$(curl -s ipv4.icanhazip.com)

# Генерация строки импорта
VMESS_JSON=$(cat <<EOF
{
  "v": "2",
  "ps": "$NAME",
  "add": "$IP",
  "port": "80",
  "id": "$UUID",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "",
  "path": "/ws",
  "tls": ""
}
EOF
)

VMESS_LINK="vmess://$(echo "$VMESS_JSON" | base64 -w 0)"

echo ""
echo "cat /usr/local/etc/xray/config.json"

echo "✅ Клиент '$NAME' добавлен!"
echo "🔐 UUID: $UUID"
echo "📲 Строка для импорта в v2rayNG:"
echo "$VMESS_LINK"
