#!/bin/bash

backupdir="backupdir"
backup="backuparchive.tar"
logfile="backupinfo.log"
hashfile="backup.md5"

logging() {
    echo "[LOG] $(date "+%F %T") | $1" | tee -a "$logfile"
}

error_log() {
    echo "[ERROR] $(date "+%F %T") | $1" >&2
    echo "[ERROR] $(date "+%F %T") | $1" >> "$logfile"
}

checkf() {
    [[ -f "$backup" ]] && (md5sum "$backup" > "$hashfile" && logging "md5 обновлён") || error_log "Отсутствует .md5 архив"
}

first() {
    tar -cf "$backup" "$backupdir" 2>>"$logfile" && (logging "Выполнен полный бекап"; checkf) || (error_log "Полный бекап провален"; exit 1)
}

main() {
    [[ ! -f "$backup" ]] && first && exit 0
    
    lasttime=$(stat -c %Y "$backup")
    
    find "$backupdir" -type f -newermt "@$lasttime" | while read -r file; do
        tar -rf "$backup" "$file" 2>>"$logfile" && logging "+$file" || error_log "Ошибка с файлом: $file"
    done
    checkf
}

main
