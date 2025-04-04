#!/bin/bash

set -e

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"

# Проверка аргументов
if [ "$#" -ne 1 ]; then
  echo "Использование: $0 <client_name>"
  echo "Пример: $0 phone"
  exit 1
fi

CLIENT_NAME=$1
CLIENT_DIR="$WG_DIR/clients/$CLIENT_NAME"

# Проверка наличия конфигурации клиента
if [ ! -d "$CLIENT_DIR" ]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден!"
  exit 1
fi

# Проверка wg0.conf
if [ ! -f "$WG_CONF" ]; then
  echo "❌ Файл $WG_CONF не найден!"
  exit 1
fi

# Получаем публичный ключ клиента
CLIENT_PUB=$(cat "$CLIENT_DIR/publickey")

echo "🔧 Удаляем клиента из конфигурации сервера..."

# Экранируем спецсимволы в публичном ключе для perl
ESCAPED_PUB=$(echo "$CLIENT_PUB" | sed 's/[&/\]/\\&/g')

# Используем perl для удаления блока с публичным ключом клиента в wg0.conf
sudo perl -i -0pe "s/# $CLIENT_NAME.*?PublicKey = $ESCAPED_PUB.*?AllowedIPs = $ESCAPED_PUB.*?//gs" "$WG_CONF"

# Удаление ключей клиента и его конфигурации
echo "🔧 Удаляем ключи и конфигурацию клиента..."
sudo rm -rf "$CLIENT_DIR"

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "✅ Клиент '$CLIENT_NAME' успешно удалён!"
