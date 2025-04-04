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

CLIENTS=()

# Заполнение списка клиентов, извлекая комментарии, начинающиеся с # client_
grep -oP '^# client_\K.*' "$WG_CONF" | while read -r CLIENT_NAME; do
  CLIENTS+=("$CLIENT_NAME")

  # Печатаем информацию о клиенте
  echo "Имя клиента: $CLIENT_NAME"
  echo "----------------------------"
done

echo "✅ Список клиентов завершён!"
