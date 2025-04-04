### Установка сервиса Xray на Ubuntu
```bash
./cli.sh install
```

### Редактирование конфигов
```bash
nano /usr/local/etc/xray/config.json
systemctl restart xray
```

### Логи
```bash
journalctl -u xray -e
journalctl -u xray -f # хвостик
```
