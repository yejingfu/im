#!/bin/bash

# setup im server

INSTALL_DIR=.
IM_SERVER=im-server-*

FILE_SERVER=file_server
LOGIN_SERVER=login_server
MSG_SERVER=msg_server
ROUTE_SERVER=route_server
MSFS_SERVER=msfs

FILE_SERVER_CONF=fileserver.conf
LOGIN_SERVER_CONF=loginserver.conf
MSG_SERVER_CONF=msgserver.conf
ROUTE_SERVER_CONF=routeserver.conf
MSFS_SERVER_CONF=msfs.conf

print_hello(){
	echo "==========================================="
	echo "$1 im server"
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

clean_yum() {
	YUM_PID=/var/run/yum.pid
	if [ -f "$YUM_PID" ]; then
		set -x
		rm -f YUM_PID
		killall yum
		set +x
	fi
}

build_im_server() {

	#yum -y install yum-fastestmirror
	clean_yum
	#yum －y install libuuid-devel
    apt-get install uuid-dev

	mkdir -p $INSTALL_DIR
	tar zxvf $IM_SERVER.tar.gz -C $INSTALL_DIR/
	if [ $? -eq 0 ]; then
		echo "unzip im-server successed."
		set -x
		cp -f ./conf/$LOGIN_SERVER_CONF $INSTALL_DIR/$IM_SERVER/$LOGIN_SERVER/
		cp -f ./conf/$MSG_SERVER_CONF $INSTALL_DIR/$IM_SERVER/$MSG_SERVER/
		cp -f ./conf/$ROUTE_SERVER_CONF $INSTALL_DIR/$IM_SERVER/$ROUTE_SERVER/
		cp -f ./conf/$FILE_SERVER_CONF $INSTALL_DIR/$IM_SERVER/$FILE_SERVER/
		cp -f ./conf/$MSFS_SERVER_CONF $INSTALL_DIR/$IM_SERVER/$MSFS_SERVER/
		
		chmod 755 $INSTALL_DIR/$IM_SERVER/restart.sh
	
		set +x
	else 
		echo "Error: unzip im-server failed."
		return 1
	fi
}

run_im_server() {
	cd $INSTALL_DIR/$IM_SERVER
	./restart.sh $LOGIN_SERVER
	./restart.sh $ROUTE_SERVER
	./restart.sh $MSG_SERVER
	./restart.sh $FILE_SERVER
	./restart.sh $MSFS_SERVER
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

		build_im_server
		run_im_server
		;;
	*)
		print_help
		;;
esac


