#!/bin/bash

case "$1" in
  install)
    bash ./install.sh
    ;;
  add)
    bash ./add.sh
    ;;
  list)
    bash ./list.sh
    ;;
  remove)
    bash ./remove.sh
    ;;
  help|--help|-h|"")
    echo "🧰 Xray CLI"
    echo ""
    echo "Использование:"
    echo "  ./xray-cli.sh install   - Установить Xray и базовый конфиг"
    echo "  ./xray-cli.sh add       - Добавить нового клиента"
    echo "  ./xray-cli.sh list      - Показать список клиентов"
    echo "  ./xray-cli.sh remove    - У
