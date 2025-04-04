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

# Заполнение списка клиентов
grep -A 3 '\[Peer\]' "$WG_CONF" | while read -r line; do
  # Ищем строки с публичным ключом и IP-адресом
  if [[ "$line" =~ PublicKey\ =\ (.*) ]]; then
    CLIENT_PUB="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ AllowedIPs\ =\ (.*) ]]; then
    CLIENT_IP="${BASH_REMATCH[1]}"

    # Ищем комментарий перед блоком клиента
    CLIENT_COMMENT=$(grep -B 1 "PublicKey = $CLIENT_PUB" "$WG_CONF" | grep '^#' | tail -n 1)

    CLIENT_NAME="${CLIENT_COMMENT//\#/}"  # Убираем знак '#' из комментария
    CLIENT_NAME="${CLIENT_NAME// /}"     # Убираем лишние пробелы

    CLIENTS+=("$CLIENT_NAME")

    # Печатаем информацию о клиенте
    echo "Имя клиента: $CLIENT_NAME"
    echo "Публичный ключ клиента: $CLIENT_PUB"
    echo "----------------------------"
  fi
done

echo "✅ Список клиентов завершён!"
