#!/bin/bash

set -e

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"
IP=$(curl -s ipv4.icanhazip.com)
SERVER_ENDPOINT="$IP:41641"

# Проверка wg0.conf
if [ ! -f "$WG_CONF" ]; then
  echo "❌ Файл $WG_CONF не найден!"
  exit 1
fi

# Получение публичного ключа сервера
SERVER_PUB=$(wg pubkey < "$WG_DIR/privatekey")

# Ввод имени клиента и IP
read -p "Введите имя клиента: " CLIENT_NAME
if [ -z "$CLIENT_NAME" ]; then
  echo "❌ Имя клиента не может быть пустым."
  exit 1
fi

read -p "Введите IP клиента (например: 10.0.0.2): " CLIENT_IP
if [ -z "$CLIENT_IP" ]; then
  echo "❌ IP клиента не может быть пустым."
  exit 1
fi

# Генерация ключей клиента
wg genkey | tee /etc/wireguard/$CLIENT_NAME-privatekey | wg pubkey > /etc/wireguard/$CLIENT_NAME-publickey

CLIENT_PRIV=$(cat /etc/wireguard/$CLIENT_NAME-privatekey)
CLIENT_PUB=$(cat /etc/wireguard/$CLIENT_NAME-publickey)

# Добавление клиента в конфиг
if grep -q "$CLIENT_PUB" "$WG_CONF"; then
  echo "⚠️ Пир с этим ключом уже есть в $WG_CONF"
else
  echo "" | sudo tee -a "$WG_CONF" > /dev/null
  echo "# $CLIENT_NAME" | sudo tee -a "$WG_CONF" > /dev/null
  echo "[Peer]" | sudo tee -a "$WG_CONF" > /dev/null
  echo "PublicKey = $CLIENT_PUB" | sudo tee -a "$WG_CONF" > /dev/null
  echo "AllowedIPs = $CLIENT_IP/32" | sudo tee -a "$WG_CONF" > /dev/null
  echo "✅ Добавлен в $WG_CONF"
fi

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

# Вывод всей конфигурации для клиента
echo "🔗 Вот полная конфигурация для подключения клиента:"
cat <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP/32

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "📄 Конфигурация клиента сгенерирована для подключения к серверу."
echo "📁 Ключи: /etc/wireguard/$CLIENT_NAME-privatekey и /etc/wireguard/$CLIENT_NAME-publickey"
