#!/bin/bash
(
    echo "Ребенок $BASHPID запущен. Родитель: $PPID"
    sleep 20
    echo "Ребенок $BASHPID проснулся. Новый родитель $PPID"
) &

echo "Родитель ($$) завершает работу."
exit 0
