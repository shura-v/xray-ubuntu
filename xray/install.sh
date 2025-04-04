#!/bin/bash

echo "🔧 Установка Xray-core..."
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

echo "🔐 Генерация X25519 ключей..."
KEYS=$(xray x25519)
PRIVATE_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
PUBLIC_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')

# Сохраняем для add-reality-user.sh
mkdir -p /etc/xray
echo "$PRIVATE_KEY" > /etc/xray/private.key
echo "$PUBLIC_KEY" > /etc/xray/public.key

# Базовый конфиг с пустым списком клиентов
cat <<EOF > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {
      "port": 8443,
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

# systemd юнит
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

systemctl daemon-reload
systemctl enable xray
systemctl restart xray

echo ""
echo "✅ Xray с REALITY установлен!"
echo "Теперь запускай ./add-reality-user.sh для добавления клиента"
