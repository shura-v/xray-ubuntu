#!/bin/bash

# Установка Xray-core
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# Пустой базовый конфиг
cat <<EOF > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {
      "port": 80,
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
echo "cat /usr/local/etc/xray/config.json"
echo "✅ Xray установлен и запущен!"
echo "Теперь используй ./add-vmess-user.sh для добавления клиента"
