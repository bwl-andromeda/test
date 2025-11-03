#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Ошибка: Этот скрипт должен быть запущен с правами root (sudo)" 
   exit 1
fi

echo "=== Удаление Process Monitor ==="

echo "Остановка и отключение таймера..."
systemctl stop process-monitor.timer 2>/dev/null || true
systemctl disable process-monitor.timer 2>/dev/null || true

echo "Остановка сервиса..."
systemctl stop process-monitor.service 2>/dev/null || true

echo "Удаление systemd юнитов..."
rm -f /etc/systemd/system/process-monitor.service
rm -f /etc/systemd/system/process-monitor.timer

echo "Удаление скрипта мониторинга..."
rm -f /usr/local/bin/monitor_process.sh

echo "Удаление файла состояния..."
rm -f /var/run/process_monitor_test.state

echo "Перезагрузка systemd daemon..."
systemctl daemon-reload

echo ""
echo "=== Удаление завершено успешно! ==="
echo ""
echo "Примечание: Лог-файл /var/log/monitoring.log НЕ был удален."
echo "Удалите его вручную если необходимо: sudo rm /var/log/monitoring.log"
