#!/bin/bash

# setup nginx

print_hello(){
	echo "==========================================="
	echo "$1 nginx"
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
	ps -ef | grep -v 'grep' | grep nginx
	if [ $? -eq 0 ]; then
		echo "Error: nginx is running."
		exit 1
	fi
}

install_nginx() {
    apt-get install nginx
	service nginx start
	if [ $? -eq 0 ]; then
  		echo "test to start nginx successed";
	else
  		echo "Error: test to stop nginx failed";
  		exit 1;
	fi
	service nginx stop
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
		print_hello	$1
		check_user
		check_os
		check_run
		install_nginx
		;;
	*)
		print_help
		;;
esac



