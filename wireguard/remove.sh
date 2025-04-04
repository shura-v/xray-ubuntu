#!/bin/bash

bash ./list.sh

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
