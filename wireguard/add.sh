#!/bin/bash

set -e

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"
IP=$(curl -s ipv4.icanhazip.com)
SERVER_ENDPOINT="$IP:51820"

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

CLIENT_DIR="$WG_DIR/clients/$CLIENT_NAME"
sudo mkdir -p "$CLIENT_DIR"
cd "$CLIENT_DIR"

# Генерация ключей клиента
wg genkey | tee privatekey | wg pubkey > publickey

CLIENT_PRIV=$(cat privatekey)
CLIENT_PUB=$(cat publickey)

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

# Генерация конфигурации клиента
cat <<EOF | sudo tee "$CLIENT_DIR/$CLIENT_NAME.conf" > /dev/null
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "📄 Конфигурация клиента сгенерирована: $CLIENT_DIR/$CLIENT_NAME.conf"
echo "📁 Ключи: $CLIENT_DIR"
echo

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "🚀 Не забудь проверить состояние WireGuard с помощью:"
echo "sudo systemctl status wg-quick@wg0"
