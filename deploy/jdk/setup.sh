#!/bin/bash

# setup jdk


JDK=jdk-7u67-linux-x64

print_hello(){
	echo "==========================================="
	echo "$1 jdk"
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

check_jdk() {
	echo "check jdk version..."
	javac -version
	if [[ $? = 0 ]]; then
		echo "Error: JDK has installed, stop install jdk"
		exit 1
	else
		echo "jdk has not installed, need to install jdk"	
	fi
}

build_jdk() {
    apt-get install python-software-properties
    add-apt-repository ppa:webupd8team/java
    apt-get update
    apt-get intall oracle-java7-intaller

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
		check_jdk
		;;
	install)
		print_hello	$1
		check_user
		check_os
		check_jdk
		build_jdk
		;;
	*)
		print_help
		;;
esac


