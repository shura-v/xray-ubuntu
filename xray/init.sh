#!/bin/bash

# Установка Xray-core
mkdir -p /usr/local/etc/xray
wget -O /usr/local/bin/xray https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
unzip -o Xray-linux-64.zip xray -d /usr/local/bin/ && \
chmod +x /usr/local/bin/xray && \
rm Xray-linux-64.zip

# UUID для клиента
UUID=$(cat /proc/sys/kernel/random/uuid)

# Конфиг
cat <<EOF > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
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

# systemd юнит
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

echo ""
echo "✅ Xray установлен и запущен!"
echo "🧾 Данные для подключения:"
echo "==============================="
echo "Протокол: VMess"
echo "IP: $(curl -s ipv4.icanhazip.com)"
echo "Порт: 80"
echo "UUID: $UUID"
echo "Path: /ws"
echo "Transport: WebSocket"
echo "Без TLS"
echo "==============================="
