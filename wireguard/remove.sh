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

# Получаем строку с номером для клиента
CLIENT_LINE=$(grep -n "# $CLIENT_NAME" "$WG_CONF" | cut -d: -f1)

if [ -z "$CLIENT_LINE" ]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден в конфиге!"
  exit 1
fi

echo "🔧 Удаляем клиента из конфигурации сервера..."

# Находим все строки, начиная с строки клиента до следующего клиента или конца
sudo sed -i "${CLIENT_LINE},/^#/d" "$WG_CONF"

# Удаление ключей клиента и его конфигурации
echo "🔧 Удаляем ключи и конфигурацию клиента..."
sudo rm -rf "$CLIENT_DIR"

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "✅ Клиент '$CLIENT_NAME' успешно удалён!"
