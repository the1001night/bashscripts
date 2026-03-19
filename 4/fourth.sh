#!/bin/bash

# Config
createusersfile="createusers.csv"
deleteusersfile="deleteusers.csv"
manageusersfile="usersroles.csv"
managegroupsfile="rolesdirectories.csv"
LOG_FILE="foutrhscript.log"

logging() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

create_users() {
    [[ ! -f "$createusersfile" ]] && echo "Файл $createusersfile не найден" && exit 1
    while IFS=, read -u 9 -r col1 col2 col3 || [ -n "$col1" ]; do
        [ -z "$col1" ] && continue
        [ -z "$col3" ] && col3="$col1"
        if useradd -m -d "/home/$col3" "$col1" > /dev/null 2>&1; then
            logging "Пользователь $col1 создан"
            echo "$col1:$col2" | chpasswd && logging "Пользователю $col1 был установлен пароль"
            sudo -u "$col1" ssh-keygen -t ed25519 -C "$col1" -f "/home/$col3/.ssh/id_ed25519" -N "$col2" > /dev/null </dev/null \
            && logging "SSH ключ для пользователя $col1 создан"
        else
            logging "Пользователь $col1 уже существует"
        fi
    done 9< "$createusersfile"
}

delete_users() {
  [[ ! -f "$deleteusersfile" ]] && echo "Файл $deleteusersfile не найден" && exit 1
  while IFS=, read -r col1 col2; do
    [[ "$col2" = "yes" ]] && col2="-r" || col2=""
    userdel $col2 $col1 > /dev/null 2>&1 
    if [ $? -eq 0 ]; then
      [[ "$col2" = "" ]] && logging "Пользователь $col1 был удалён." || logging "Пользователь $col1 и его домашняя директория были удалены."
    fi
  done < "$deleteusersfile"
}

manage_users() {
  local action="$1"
  if [ "$action" = "users" ]; then
    [[ ! -f "$manageusersfile" ]] && echo "Файл $manageusersfile не найден" && exit 1

    while IFS=, read -r user group || [ -n "$user" ]; do
      [ -z "$user" ] && continue
      if id "$user" > /dev/null 2>&1 && getent group "$group" > /dev/null 2>&1; then
        usermod -aG "$group" "$user" && logging "Пользователь $user добавлен в группу $group"
      else
        logging "Ошибка: пользователь $user или группа $group не существует"
      fi
    done < "$manageusersfile"

  elif [ "$action" = "groups" ]; then
    [[ ! -f "$managegroupsfile" ]] && echo "Файл $managegroupsfile не найден" && exit 1
    
    while IFS=, read -r group dir1 dir2 || [ -n "$group" ]; do
      [ -z "$group" ] && continue
      getent group "$group" > /dev/null 2>&1 || (groupadd "$group" && logging "Группа $group создана")
      for dir in "$dir1" "$dir2"; do
        [ -z "$dir" ] && continue
        [ ! -d "$dir" ] && mkdir -p "$dir" && logging "Директория $dir создана"
        chown -R :"$group" "$dir"
        chmod -R 770 "$dir"
        logging "Права на $dir обновлены для группы $group"
      done
    done < "$managegroupsfile"
  else
    show_info
  fi
}

show_info() {
  echo "Правильное использование: "
  echo "$0 create - для создания пользователей на основе $createusersfile"
  echo "$0 delete - для удаления пользователей и их домашних каталогов на основе $deleteusersfile"
  echo "$0 manage users/groups - для управления пользователями/директориями групп"
}

if [ "$1" = 'create' ]; then
  touch $LOG_FILE
  create_users
elif [ "$1" = 'delete' ]; then
  touch $LOG_FILE
  delete_users
elif [ "$1" = 'manage' ]; then
  touch $LOG_FILE
  manage_users "$2"
else
  show_info
fi
