#!/bin/bash

COMMAND=$1
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  echo ""
  echo "🧭 Xray CLI"
  echo ""
  echo "Использование:"
  echo "  ./cli.sh install     — установка Xray (VLESS + REALITY)"
  echo "  ./cli.sh add         — добавить клиента"
  echo "  ./cli.sh list        — список клиентов (в разработке)"
  echo "  ./cli.sh remove      — удалить клиента (в разработке)"
  echo ""
}

install() {
  read -p "Введите порт для Xray [по умолчанию 8443]: " PORT
  PORT=${PORT:-8443}

  echo "🔧 Установка Xray-core..."
  bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

  echo "🔐 Генерация X25519 ключей..."
  KEYS=$(xray x25519)
  PRIVATE_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
  PUBLIC_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')

  mkdir -p /etc/xray
  echo "$PRIVATE_KEY" > /etc/xray/private.key
  echo "$PUBLIC_KEY" > /etc/xray/public.key

  cat <<EOF > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "www.cloudflare.com:443",
          "xver": 0,
          "serverNames": ["www.cloudflare.com"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["12345678"]
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

  cat <<EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray REALITY Service
After=network.target

[Service]
ExecStart=/usr/local/bin/xray -config /usr/local/etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  sudo ufw allow $PORT/tcp
  systemctl daemon-reload
  systemctl enable xray
  systemctl restart xray

  echo ""
  echo "✅ Xray установлен с REALITY на порту $PORT!"
  echo "Public Key для клиента: $PUBLIC_KEY"
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
