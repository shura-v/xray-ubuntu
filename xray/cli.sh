#!/bin/bash

COMMAND=$1
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  echo ""
  echo "🧭 Xray CLI"
  echo ""
  echo "Использование:"
  echo "  ./cli install     — установка Xray"
  echo "  ./cli add         — добавить клиента"
  echo "  ./cli list        — список клиентов"
  echo "  ./cli remove      — удалить клиента"
  echo ""
  echo "Примеры:"
  echo "  ./cli add"
  echo "  ./cli list"
  echo ""
}

install() {
  # Запрашиваем порт
  read -p "Введите порт для Xray (например: 443): " PORT

  # Если порт пустой, то по умолчанию 443
  PORT=${PORT:-443}

  # Установка Xray
  bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

  # Обновление конфигурации
  cat <<EOF > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ws"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

  # Systemd юнит
  cat <<EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=/usr/local/bin/xray -config /usr/local/etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  # Запуск
  systemctl daemon-reload
  systemctl enable xray
  systemctl start xray

  echo "✅ Xray установлен и запущен на порту $PORT!"
  echo "Теперь используй ./cli.sh add для добавления клиента"
}

case "$COMMAND" in
  install)
    install
    ;;
  add)
    bash "$SCRIPTS_DIR/add.sh"
    ;;
  list)
    bash "$SCRIPTS_DIR/list.sh"
    ;;
  remove)
    bash "$SCRIPTS_DIR/remove.sh"
    ;;
  *)
    show_help
    ;;
esac
