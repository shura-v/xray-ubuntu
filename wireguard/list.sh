#!/bin/bash

set -e

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"

# Проверка наличия конфигурации WireGuard
if [ ! -f "$WG_CONF" ]; then
  echo "❌ Файл конфигурации WireGuard не найден: $WG_CONF"
  exit 1
fi

# Перечисление всех клиентов из конфигурации
echo "📋 Список клиентов WireGuard:"
echo "----------------------------"

grep -A 3 '\[Peer\]' "$WG_CONF" | while read -r line; do
  # Ищем строки с публичным ключом и IP-адресом
  if [[ "$line" =~ PublicKey\ =\ (.*) ]]; then
    CLIENT_PUB="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ AllowedIPs\ =\ (.*) ]]; then
    CLIENT_IP="${BASH_REMATCH[1]}"

    CLIENT_NAME="client_$CLIENT_PUB"  # Имя клиента будет основано на публичном ключе

    echo "Имя клиента: $CLIENT_NAME"
    echo "IP клиента: $CLIENT_IP"
    echo "Публичный ключ клиента: $CLIENT_PUB"
    echo "Путь к конфигу клиента: (не используется в текущем формате)"
    echo "----------------------------"
  fi
done

echo "✅ Список клиентов завершён!"
