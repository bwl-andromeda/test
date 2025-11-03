#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Ошибка: Этот скрипт должен быть запущен с правами root (sudo)" 
   exit 1
fi

echo "=== Установка Process Monitor ==="

echo "Копирование скрипта мониторинга..."
cp process.sh /usr/local/bin/
chmod +x /usr/local/bin/process.sh

echo "Установка systemd юнитов..."
cp process.service /etc/systemd/system/
cp process.timer /etc/systemd/system/

echo "Создание лог-файла..."
touch /var/log/monitoring.log
chmod 644 /var/log/monitoring.log

echo "Перезагрузка systemd daemon..."
systemctl daemon-reload

echo "Включение и запуск таймера..."
systemctl enable process.timer
systemctl start process.timer

echo ""
echo "=== Статус установки ==="
systemctl status process.timer --no-pager

echo ""
echo "=== Установка завершена успешно! ==="
echo ""
echo "Полезные команды:"
echo "  - Проверить статус таймера: systemctl status process-monitor.timer"
echo "  - Проверить логи: journalctl -u process-monitor.service -f"
echo "  - Просмотреть лог мониторинга: tail -f /var/log/monitoring.log"
echo "  - Остановить мониторинг: systemctl stop process-monitor.timer"
echo "  - Запустить мониторинг: systemctl start process-monitor.timer"
echo "  - Отключить автозапуск: systemctl disable process-monitor.timer"
