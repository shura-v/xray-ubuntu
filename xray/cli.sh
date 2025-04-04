#!/bin/bash

COMMAND=$1
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  echo ""
  echo "🧭 Xray CLI"
  echo ""
  echo "Использование:"
  echo "  ./cli.sh install     — установка Xray"
  echo "  ./cli.sh add         — добавить клиента"
  echo "  ./cli.sh list        — список клиентов"
  echo "  ./cli.sh remove      — удалить клиента"
}

case "$COMMAND" in
  install)
    bash "$SCRIPTS_DIR/install.sh"
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
