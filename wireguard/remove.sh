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

    CLIENT_NAME="client_$CLIENT_PUB"  # Имя клиента будет основано на публичном ключе

    CLIENTS+=("$CLIENT_NAME")

    # Печатаем информацию о клиенте
    echo "Имя клиента: $CLIENT_NAME"
    echo "IP клиента: $CLIENT_IP"
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

echo "🔧 Удаляем клиента '$CLIENT_NAME' из конфигурации сервера..."

# Получаем строку с номером для клиента
CLIENT_LINE=$(grep -n "# $CLIENT_NAME" "$WG_CONF" | cut -d: -f1)

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
