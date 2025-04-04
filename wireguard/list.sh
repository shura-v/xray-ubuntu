#!/bin/bash

set -e

WG_DIR="/etc/wireguard"
CLIENTS_DIR="$WG_DIR/clients"

# Проверка наличия директории с клиентами
if [ ! -d "$CLIENTS_DIR" ]; then
  echo "❌ Директория с клиентами не найдена: $CLIENTS_DIR"
  exit 1
fi

# Перечисление всех клиентов
echo "📋 Список клиентов WireGuard:"
echo "----------------------------"
for CLIENT_DIR in "$CLIENTS_DIR"/*; do
  if [ -d "$CLIENT_DIR" ]; then
    CLIENT_NAME=$(basename "$CLIENT_DIR")
    CLIENT_IP=$(cat "$CLIENT_DIR/$CLIENT_NAME.conf" | grep "Address" | cut -d '=' -f 2 | tr -d ' ')
    CLIENT_PUB=$(cat "$CLIENT_DIR/publickey")
    echo "Имя клиента: $CLIENT_NAME"
    echo "IP клиента: $CLIENT_IP"
    echo "Публичный ключ клиента: $CLIENT_PUB"
    echo "Путь к конфигу клиента: $CLIENT_DIR/$CLIENT_NAME.conf"
    echo "----------------------------"
  fi
done

echo "✅ Список клиентов завершён!"
