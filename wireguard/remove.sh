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

# Если передан аргумент, используем его как имя клиента для удаления
if [ "$#" -eq 1 ]; then
  CLIENT_NAME=$1
else
  # Если аргумент не передан, запрашиваем у пользователя выбор
  read -p "Введите имя клиента для удаления: " CLIENT_NAME
fi

# Проверка на существование клиента
if [[ ! " ${CLIENTS[@]} " =~ " $CLIENT_NAME " ]]; then
  echo "❌ Клиент '$CLIENT_NAME' не найден в конфиге!"
  exit 1
fi

# Находим публичный ключ клиента из его имени
CLIENT_PUB=$(grep -A 3 "$CLIENT_NAME" "$WG_CONF" | grep -m 1 "PublicKey" | cut -d' ' -f3)

echo "🔧 Удаляем клиента '$CLIENT_NAME' с публичным ключом '$CLIENT_PUB' из конфигурации сервера..."

# Находим строку с номером для публичного ключа
CLIENT_LINE=$(grep -n "PublicKey = $CLIENT_PUB" "$WG_CONF" | cut -d: -f1)

# Проверка, что публичный ключ найден
if [ -z "$CLIENT_LINE" ]; then
  echo "❌ Клиент с публичным ключом '$CLIENT_PUB' не найден в конфигурации WireGuard!"
  exit 1
fi

# Находим строку для удаления (блок клиента) начиная с найденной строки до следующего комментария или конца
echo "Удаление блока клиента с публичным ключом '$CLIENT_PUB'..."
sudo sed -i "${CLIENT_LINE},/^$/d" "$WG_CONF"

# Удаляем ключи клиента
sudo rm -f "$WG_DIR/$CLIENT_NAME-privatekey"
sudo rm -f "$WG_DIR/$CLIENT_NAME-publickey"

# Перезапуск WireGuard
echo "🔄 Перезапускаем WireGuard..."
sudo systemctl restart wg-quick@wg0

echo "✅ Клиент '$CLIENT_NAME' успешно удалён из конфигурации!"
