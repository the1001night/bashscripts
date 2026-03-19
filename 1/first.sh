#!/bin/sh

DEBUG=false
LOGDIR="$(pwd)/script_logs"
LOGFILE="$LOGDIR/logs-$(date '+%Y-%m-%d-%H:%M:%S').log"
DTR=3

e_debug() {
  if [ "$DEBUG" = true ]; then
    set -x
  fi
}

logging() {
  local message="$1"
  local status="$2"
  if [ "$status" = 2 ]; then
    echo -e "[ERROR | $(date '+%Y-%m-%d %H:%M:%S')] $message" >&2 >> $LOGFILE
  else
    echo -e "[LOG   | $(date '+%Y-%m-%d %H:%M:%S')] $message" >> $LOGFILE
  fi
}

get_cpu_info() {
  if ! cpu_usage=$(top -bn1 | grep "Cpu(s)" 2>&1); then
    logging "$cpu_usage Не удалось получить данные о работе CPU" 2
  else
    logging "$cpu_usage" 1
  fi
}

get_mem_info() {
  if ! mem_usage=$(free -h 2>&1); then
    logging "$mem_usage Не удалось получить данные о работе ОЗУ" 2
  else
    logging "\n$mem_usage" 1
  fi
}

get_disk_info() {
  if ! disk_usage=$(df -h 2>&1); then
    logging "$disk_usage Не удалось получить данные о работе дисков" 2
  else
    logging "\n$disk_usage" 1
  fi
}


log_rotate() {
  find "$LOGDIR" -type f -name "*.log" -mtime +3 -exec rm -f {} \;
}

monitoring() {
  get_cpu_info
  get_mem_info
  get_disk_info
}

trap 'exit 0' SIGINT SIGTERM

if [ "$1" = "-v" ]; then
  DEBUG=true
fi
e_debug

mkdir -p $LOGDIR
touch $LOGFILE

while true; do
  monitoring
  log_rotate
  sleep 60
done
