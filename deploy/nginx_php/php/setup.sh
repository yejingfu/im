#!/bin/bash

# setup php

PHP=php-5.6.3
PHP_DOWNLOAD_PATH=http://cn2.php.net/distributions/$PHP.tar.gz
INSTALL_DIR=/usr/local/php5

PHP_FPM_CONF=php-fpm.conf
PHP_INI=php.ini
MAKE=make

print_hello(){
	echo "==========================================="
	echo "$1 php"
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
	ps -ef | grep -v 'grep' | grep php-fpm
	if [ $? -eq 0 ]; then
		echo "Error: php-fpm is running."
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


download() {
	if [ -f "$1" ]; then
		echo "$1 existed."
	else
		echo "$1 not existed, begin to download..."
		wget $2
		if [ $? -eq 0 ]; then
			echo "download $1 successed";
		else
			echo "Error: download $1 failed";
			return 1;
		fi
	fi
	return 0
}

# building php
build_php() {
	gunzip -c $PHP.tar.gz | tar xf -
	cd $PHP
	./configure --prefix=$INSTALL_DIR \
		  --with-config-file-path=$INSTALL_DIR/etc \
	    --enable-fpm \
	    --enable-gd-native-ttf \
	    --with-mysql=mysqlnd \
	    --with-mysqli=mysqlnd \
	    --with-pdo-mysql=mysqlnd \
	    --with-curl	\
	    #--with-apxs2 \
	    --with-zlib \
	    --with-zlib-dir \
	    --with-libxml-dir \
	    --with-freetype-dir \
	    --with-jpeg-dir \
	    --with-png-dir \
	    --with-gd 
	    
	$MAKE
	if [ $? -eq 0 ]; then
	  echo "make php successed";
	else
	  echo "Error: make php failed";
	  return 1;
	fi
	$MAKE install
	if [ $? -eq 0 ]; then
	  echo "install php successed";
	else
	  echo "Error: install php failed";
	  return 1;
	fi
	cd ..
	return 0
}

# modify and copy php.ini
modify_php() {
	set -x
	cp  ./conf/$PHP_FPM_CONF  $INSTALL_DIR/etc/$PHP_FPM_CONF
	chmod 755 $INSTALL_DIR/etc/$PHP_FPM_CONF
	cp  ./conf/$PHP_INI $INSTALL_DIR/etc/$PHP_INI
	chmod 755 $INSTALL_DIR/etc/$PHP_INI

	killall php-fpm
	$INSTALL_DIR/sbin/php-fpm
	set +x
	netstat -antpl

}

modify_php2() {
	set -x
	#cp  ./conf/$PHP_FPM_CONF  $INSTALL_DIR/etc/$PHP_FPM_CONF
	#chmod 755 $INSTALL_DIR/etc/$PHP_FPM_CONF
	cp  ./conf/$PHP_INI /etc/php5/fpm/$PHP_INI
	chmod 755 $INSTALL_DIR/etc/$PHP_INI

	killall php-fpm
	#$INSTALL_DIR/sbin/php-fpm
    service php5-fpm restart
	set +x
	netstat -antpl

}


build_zlib() {
	clean_yum

	yum -y install zlib-devel
	if [ $? -eq 0 ]; then
		echo "yum install zlib-devel successed."
	else
		echo "Error: yum install zlib-devel failed."
		return 1;
	fi
}

build_jpeg() {
	clean_yum
	yum -y install libjpeg-devel
	if [ $? -eq 0 ]; then
		echo "yum install libjpeg-devel successed."
	else
		echo "Error: yum install libjpeg-devel failed."
		return 1;
	fi
}

build_freetype() {
	clean_yum
	yum -y install freetype-devel
	if [ $? -eq 0 ]; then
		echo "yum install freetype-devel successed."
	else
		echo "Error: yum install freetype-devel failed."
		return 1;
	fi
}

build_png() {
	clean_yum
	yum -y install libpng-devel
	if [ $? -eq 0 ]; then
		echo "yum install libpng-devel successed."
	else
		echo "Error: yum install libpng-devel failed."
		return 1;
	fi
}


build_gd() {
	clean_yum
	yum -y install php-gd
	if [ $? -eq 0 ]; then
		echo "yum install php-gd successed."
	else
		echo "Error: yum install php-gd failed."
		return 1;
	fi
}

build_xml() {
	clean_yum
	yum -y install libxml2-devel
	if [ $? -eq 0 ]; then
		echo "yum install libxml2-devel successed."
	else
		echo "Error: yum install libxml2-devel failed."
		return 1;
	fi
}

build_curl() {
	clean_yum
	yum -y install curl-devel
	if [ $? -eq 0 ]; then
		echo "yum install curl-devel successed."
	else
		echo "Error: yum install curl-devel failed."
		return 1;
	fi
}

build_all()
{
	##yum -y install yum-fastestmirror

	# build_zlib
    apt-get install zlib1g-dev
	if [ $? -eq 0 ]; then
		echo "build zlib successed."
	else
		echo "Error: build zlib failed."
		exit 1
	fi


	# build_jpeg
    apt-get install libjpeg-dev
	if [ $? -eq 0 ]; then
		echo "build jpeg successed."
	else
		echo "Error: build jpeg failed."
		exit 1
	fi

	#build_freetype
    apt-get install libfreetype6-dev freetype*
	if [ $? -eq 0 ]; then
		echo "build freetype successed."
	else
		echo "Error: build freetype failed."
		exit 1
	fi

	#build_png
    apt-get install libpng-dev
	if [ $? -eq 0 ]; then
		echo "build png successed."
	else
		echo "Error: build png failed."
		exit 1
	fi

	#build_gd
    apt-get install php5-gd
	if [ $? -eq 0 ]; then
		echo "build gd successed."
	else
		echo "Error: build gd failed."
		exit 1
	fi

	#build_xml
    apt-get install libxml2-dev
	if [ $? -eq 0 ]; then
		echo "build xml successed."
	else
		echo "Error: build xml failed."
		exit 1
	fi

	#build_curl
    #apt-get install php5-curl
    apt-get install curl libc6 libcurl3
	if [ $? -eq 0 ]; then
		echo "build curl successed."
	else
		echo "Error: build curl failed."
		exit 1
	fi

	download $PHP.tar.gz $PHP_DOWNLOAD_PATH
	if [ $? -eq 1 ]; then
  		exit 1;
	fi

	mkdir -p $INSTALL_DIR

	build_php
	if [ $? -eq 1 ]; then
		exit 1
	fi  
	modify_php

#    apt-get install php5-fpm php5-cli php5-mysql -y
#    modify_php2
}

run_php() {
    #killall php-fpm
	#$INSTALL_DIR/sbin/php-fpm
    service php5-fpm stop
    service php5-fpm start
	set +x
	netstat -antpl
}

print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- check & run scripts to install"
    echo "  $0 run --- run php daemon server"
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
		build_all
		;;
    run)
        run_php
        ;;
	*)
		print_help
		;;
esac



