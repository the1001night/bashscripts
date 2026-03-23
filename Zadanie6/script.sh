#!/bin/bash

packet_manager() {
    local os=$1
    case $os in
	    debian|ubuntu)
		    PM="apt-get"
		    ;;
	    arch)
		    PM="pacman"
		    SKIP="--noconfirm"
		    INSTALL="-S"
		;;
	    centos|rhel|fedora)
    		if command -v dnf >/dev/null 2>&1; then
        	    PM="dnf"
    		else
        	    PM="yum"
    		fi
		;;
    esac
}

configuration() {
    echo "<h1>Скрипт сработал! Сервер на базе $ID запущен.</h1>" | sudo tee /var/www/html/index.html
    sudo systemctl enable --now ${APACHE_NAMES[$PM]}
    sudo systemctl enable --now postgresql
    sudo systemctl start postgresql
    if [ "$PM" == "dnf" ] || [ "$PM" == "yum" ]; then
        sudo postgresql-setup --initdb
    fi
}

test_db() {
    sudo -u postgres psql -c "CREATE DATABASE test_db;"
    sudo -u postgres psql -d test_db -c "CREATE TABLE users (id serial PRIMARY KEY, name varchar(50));"
    sudo -u postgres psql -d test_db -c "INSERT INTO users (name) VALUES ('TestUser');"
}

firewall() {
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow 80/tcp
        sudo ufw allow 5432/tcp
        sudo ufw --force enable

    elif command -v firewall-cmd >/dev/null 2>&1; then
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-port=5432/tcp
        sudo firewall-cmd --reload
    fi
}

source /etc/os-release
OS=$ID
SKIP="-y"
INSTALL="install"
packet_manager "$ID"
source packages.conf
APACHE_NAME=${APACHE_NAMES[$PM]}
DB_NAME=${DB_NAMES[$PM]}

sudo $PM $INSTALL $SKIP $APACHE_NAME $DB_NAME
configuration
test_db
firewall
