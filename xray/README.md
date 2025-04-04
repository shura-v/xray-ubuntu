### Редактирование конфигов
```
nano /usr/local/etc/xray/config.json
systemctl restart xray
```

### Статус
```
systemctl status xray
```

### Логи
```
journalctl -u xray -e
journalctl -u xray -f # хвостик
```
