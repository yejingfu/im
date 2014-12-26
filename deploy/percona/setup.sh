#!/bin/bash

# setup percona

MYSQL_PASSWORD=123456
IM_SQL=im.sql
MYSQL_CONF=mysql.cnf

print_hello(){
  echo "==========================================="
  echo "$1 percona"
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

check_run() {
  ps -ef | grep -v 'grep' | grep mysqld
  if [ $? -eq 0 ]; then
    echo "Error: mysql is running."
    exit 1
  fi
}

build_ssl() {
  #yum -y install openssl-devel
  apt-get install libssl-dev   ## ubuntu
  if [ $? -eq 0 ]; then
    echo "apt-get install libssl-dev successed."
  else
    echo "Error: apt-get install libssl-dev failed."
    return 1;
  fi
}


build_percona() {
  apt-get install percona-server-server-5.5 percona-server-client-5.5

  if [ -f ./conf/$MYSQL_CONF ]; then
    cp -f ./conf/$MYSQL_CONF /etc/
  else
    echo "Error: $MYSQL_CONF is not existed";
    return 1;
  fi
}

run_percona() {
	PROCESS=$(pgrep mysql)
	if [ -z "$PROCESS" ]; then 
		echo "no mysql is running..." 
		service mysql start
		if [ $? -eq 0 ]; then
			echo "start percona successed."
		else
			echo "Error: start percona failed."
			return 1
		fi
	else 
		echo "Warning: mysql is running"
	fi
}	

set_password() {
	mysqladmin -u root password $MYSQL_PASSWORD
	if [ $? -eq 0 ]; then
		echo "set percona root password successed."
	else
		echo "Error: set percona root password failed."
		return 1
	fi
}


create_database() {
	cd ./conf/
	if [ -f "$IM_SQL" ]; then
		echo "$IM_SQL existed, begin to run $IM_SQL"
	else
		echo "Error: $IM_SQL not existed."
		cd ..
		return 1
	fi

	mysql -u root -p$MYSQL_PASSWORD < $IM_SQL
	if [ $? -eq 0 ]; then
		echo "run $IM_SQL successed."
		cd ..
	else
		echo "Error: run $IM_SQL failed."
		cd ..
		return 1
	fi
}

build_all() {
	build_percona
	if [ $? -eq 0 ]; then
		echo "build percona successed."
	else
		echo "Error: build percona failed."
		exit 1
	fi

	run_percona
	if [ $? -eq 0 ]; then
		echo "run percona successed."
	else
		echo "Error: run percona failed."
		exit 1
	fi

#	set_password
#	if [ $? -eq 0 ]; then
#		echo "set password successed."
#	else
#		echo "Error: set password failed."
#		exit 1
#	fi

	create_database
	if [ $? -eq 0 ]; then
		echo "create database successed."
	else
		echo "Error: create database failed."
		exit 1
	fi	
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
		check_run
		;;
	install)
		print_hello $1
		check_user
		check_os
		check_run
		build_all
		;;
	*)
		print_help
		;;
esac


