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

# Проверка наличия конфигурации WireGuard
if [ ! -f "$WG_CONF" ]; then
  echo "❌ Файл конфигурации WireGuard не найден: $WG_CONF"
  exit 1
fi

# Получаем строку с номером для клиента
CLIENT_LINE=$(grep -n "# $CLIENT_NAME" "$WG_CONF" | cut -d: -f1)

if [ -z "$CLIENT_LINE" ]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден в конфиге!"
  exit 1
fi

echo "🔧 Удаляем клиента '$CLIENT_NAME' из конфигурации сервера..."

# Находим все строки, начиная с строки клиента до следующего клиента или конца
# Удаляем блок клиента, включая его данные в конфиге
sudo sed -i "${CLIENT_LINE},/^#/d" "$WG_CONF"

# Удаляем ключи клиента
sudo rm -f "$WG_DIR/$CLIENT_NAME-privatekey"
sudo rm -f "$WG_DIR/$CLIENT_NAME-publickey"

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "✅ Клиент '$CLIENT_NAME' успешно удалён из конфигурации!"
