#!/bin/bash

# setup db_proxy

INSTALL_DIR=.
#DBPROXY=ttjavaserverPack
DBPROXY=businesspack
LISTEN_PORT=11000
REDIS_CONF=cache-online.properties
MYSQL_CONF=db-online.properties
COMMON_CONF=common-online.properties

print_hello(){
	echo "==========================================="
	echo "$1 db proxy"
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

build_db_proxy(){
	mkdir -p $INSTALL_DIR
	tar zxvf $DBPROXY.tar.gz -C $INSTALL_DIR/
 	if [ $? -eq 0 ]; then
 		echo "unzip $DBPROXY successed."
 		set -x 
		cp -f ./conf/$REDIS_CONF $INSTALL_DIR/$DBPROXY/
		cp -f ./conf/$MYSQL_CONF $INSTALL_DIR/$DBPROXY/
		cp -f ./conf/$COMMON_CONF $INSTALL_DIR/$DBPROXY/
		set +x
 	else	
 		echo "Error: unzip $DBPROXY failed."
 		return 1
 	fi
}

run_db_proxy(){
	echo "start DB PROXY..."
	cd $INSTALL_DIR/$DBPROXY
	chmod +x startup.sh
 	./startup.sh $LISTEN_PORT
}


print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- run scripts to install"
    echo "  $0 run --- run server"
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
		build_db_proxy
		run_db_proxy
		;;
    run)
        print_hello $1
        check_user
        check_os
        run_db_proxy
        ;;
	*)
		print_help
		;;
esac






