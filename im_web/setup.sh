#!/bin/bash

# setup web
PHP_WEB=im
PHP_WEB_SETUP_PATH=/var/www/html
PHP_DB_CONF=db.php
PHP_DB_CONF_PATH=$PHP_WEB_SETUP_PATH/$PHP_WEB/TT/protected/config
PHP_NGINX_CONF=im.com.conf
PHP_NGINX_CONF_PATH=/etc/nginx/conf.d

print_hello(){
	echo "==========================================="
	echo "$1 im web"
	echo "==========================================="
}

check_user() {
  if [ $(id -u) != "0" ]; then
    echo "You must run the script as root user"
    exit 1
  fi
}

check_os() {
  OSVER=$(cat /etc/issue)
  OSBIT=$(getconf LONG_BIT)
  if [[ $OSVER =~ "Ubuntu" ]]; then
    if [ $OSBIT == 64 ]; then
      return 0
    else
      echo "Error: OS must be Ubuntu 64 to run this script."
      exit 1
    fi
  else
    echo "Error: OS must be Ubuntu 64 to run this script."
    exit 1
  fi
}

build_web(){
	if [ -d $PHP_WEB ]; then
		echo "$PHP_WEB has existed."
	else
		unzip $PHP_WEB.zip
		if [ $? -eq 0 ]; then
			echo "unzip $PHP_WEB successed."
		else
			echo "Error: unzip $PHP_WEB failed."
		return 1
		fi
	fi

	set -x
	mkdir -p $PHP_WEB_SETUP_PATH
	cp -r $PHP_WEB/ $PHP_WEB_SETUP_PATH
	cp ./conf/$PHP_DB_CONF $PHP_DB_CONF_PATH/
	set +x

	if [ -f $PHP_NGINX_CONF_PATH/default.conf ]; then
		rm $PHP_NGINX_CONF_PATH/default.conf
		echo "remove $PHP_NGINX_CONF_PATH/default.conf successed."
	fi
	set -x
	cp ./conf/$PHP_NGINX_CONF $PHP_NGINX_CONF_PATH/
	chmod -R 777 $PHP_WEB_SETUP_PATH/$PHP_WEB/
	set +x
	service nginx stop
	service nginx start
	return 0
}

print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- check & run scripts to install"
}

case $1 in
	check)
		print_hello $1
		check_user
		check_os
		;;
	install)
		print_hello $1
		check_user
		check_os
		build_web
		;;
	*)
		print_help
		;;
esac


