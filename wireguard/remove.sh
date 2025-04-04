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

# Если передан аргумент, используем его как имя клиента для удаления
if [ "$#" -eq 1 ]; then
  CLIENT_NAME=$1
else
  # Если аргумент не передан, запрашиваем у пользователя выбор
  read -p "Введите имя клиента для удаления: " CLIENT_NAME
fi

# Добавляем префикс client_ для имени, если его нет
if [[ ! "$CLIENT_NAME" =~ ^client_ ]]; then
  CLIENT_NAME="client_$CLIENT_NAME"
fi

# Проверка на существование клиента
if [[ ! " ${CLIENTS[@]} " =~ " $CLIENT_NAME " ]]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден в конфиге!"
  exit 1
fi

# Находим строку с номером для комментария клиента
CLIENT_COMMENT="# $CLIENT_NAME"
CLIENT_LINE=$(grep -n "$CLIENT_COMMENT" "$WG_CONF" | cut -d: -f1)

# Проверка, что комментарий найден
if [ -z "$CLIENT_LINE" ]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден в конфигурации WireGuard!"
  exit 1
fi

# Находим все строки, начиная с строки комментария до следующего комментария или конца
echo "Удаление клиента '$CLIENT_NAME' с линии: $CLIENT_LINE"
sudo sed -i "${CLIENT_LINE},/^#/d" "$WG_CONF"

# Удаляем ключи клиента
sudo rm -f "$WG_DIR/$CLIENT_NAME-privatekey"
sudo rm -f "$WG_DIR/$CLIENT_NAME-publickey"

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "✅ Клиент '$CLIENT_NAME' успешно удалён из конфигурации!"
