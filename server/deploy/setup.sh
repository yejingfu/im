#!/bin/bash

REDIS=redis
MYSQL=percona
NGINX_PHP=nginx_php
NGINX=nginx
PHP=php
JDK=jdk

IM_WEB=im_web
IM_SERVER=im_server
IM_DB_PROXY=im_db_proxy
CUR_DIR=

SETUP_PROGRESS=setup.progress
REDIS_SETUP_BEGIN=0
REDIS_SETUP_SUCCESS=0
MYSQL_SETUP_BEGIN=0
MYSQL_SETUP_SUCCESS=0
NGINX_SETUP_BEGIN=0
NGINX_SETUP_SUCCESS=0
PHP_SETUP_BEGIN=0
PHP_SETUP_SUCCESS=0
JDK_SETUP_BEGIN=0
JDK_SETUP_SUCCESS=0
IM_WEB_SETUP_BEGIN=0
IM_WEB_SETUP_SUCCESS=0
IM_SERVER_SETUP_BEGIN=0
IM_SERVER_SETUP_SUCCESS=0
IM_DB_PROXY_SETUP_BEGIN=0
IM_DB_PROXY_SETUP_SUCCESS=0

ensure_root() {
  if [ $(id -u) != "0" ]; then
    echo "You must run the script as root user"
    exit 1
  fi
}

ensure_ubuntu() {
  OSVER=$(cat /etc/issue)
  OSBIT=$(getconf LONG_BIT)
  echo "OS version: ${OSVER} and OS bit: ${OSBIT}"
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

initialize() {
  ### 1, get current directory
  case $0 in
    /*)
      SCRIPT="$0"
      ;;
    *)
      PWD_DIR=$(pwd)
      SCRIPT="${PWD_DIR}/$0"
      ;;
  esac
  CHANGED=true
  while [ "X$CHANGED" != "X" ]
  do
    SAFE=`echo $SCRIPT | sed -e 's; ;:;g'`
    TOKENS=`echo $SAFE | sed -e 's;/; ;g'`
    REAL=
    for C in $TOKENS; do
      C=`echo $C | sed -e 's;:; ;g'`
      REAL="$REAL/$C"
      ## relove if it's link
      while [ -h "$REAL" ] ; do
        LS="`ls -ld "$REAL"`"
        LINK="`expr "$LS" : '.*->\(.*\)$'`"
        if expr "$LINK" : '/.*' > /dev/null; then
          REAL="$LINK"
        else
          REAL="`dirname "$REAL"`""$/$LINK"
        fi
      done
    done   ## for

    if [ "$REAL" = "$SCRIPT" ]
    then
      CHANGED=""
    else
      SCRIPT="$REAL"
    fi
  done   ## ["X$CHANGED" != "X"]
  CUR_DIR=$(dirname "${REAL}")
  echo "current dir: ${CUR_DIR}"
}

setup_begin() {
  # example:   redis start   
  echo "$1 start" >> $CUR_DIR/$SETUP_PROGRESS  
}

setup_success() {
  # example:   redis success  
  echo "$1 success" >> $CUR_DIR/$SETUP_PROGRESS  
}

get_setup_process() {
  if [ -f $CUR_DIR/$SETUP_PROGRESS ]; then
    while read line
    do
      echo "get_setup_process: ${line}"
      case $line in 
        "$REDIS start")
          REDIS_SETUP_BEGIN=1
          ;;
        "$REDIS success")
          REDIS_SETUP_SUCCESS=1
          ;;
        "$MYSQL start")
          MYSQL_SETUP_BEGIN=1
          ;;
        "$MYSQL success")
          MYSQL_SETUP_SUCCESS=1
          ;;
        "$NGINX start")
          NGINX_SETUP_BEGIN=1
          ;;
        "$NGINX success")
          NGINX_SETUP_SUCCESS=1
          ;;
        "$PHP start")
          PHP_SETUP_BEGIN=1
          ;;
        "$PHP success")
          PHP_SETUP_SUCCESS=1
          ;;
        "$JDK start")
          JDK_SETUP_BEGIN=1
          ;;
        "$JDK success")
          JDK_SETUP_SUCCESS=1
          ;;
        "$IM_WEB start")
          IM_WEB_SETUP_BEGIN=1
          ;;
        "$IM_WEB success")
          IM_WEB_SETUP_SUCCESS=1
          ;;
        "$IM_SERVER start")
          IM_SERVER_SETUP_BEGIN=1
          ;;
        "$IM_SERVER success")
          IM_SERVER_SETUP_SUCCESS=1
          ;;
        "$IM_DB_PROXY start")
          IM_DB_PROXY_SETUP_BEGIN=1
          ;;
        "$IM_DB_PROXY success")
          IM_DB_PROXY_SETUP_SUCCESS=1
          ;;
        *)
          echo "unknown setup progress: $line "
          ;;
      esac
    done < $CUR_DIR/$SETUP_PROGRESS
  fi
}

check_redis() {
  cd $REDIS
  chmod +x setup.sh
  ./setup.sh check
  if [ $? -eq 0 ]; then
    cd $CUR_DIR
  else
    return 1
  fi
}

build_redis() {
  cd $REDIS
  chmod +x setup.sh
  setup_begin $REDIS
  ./setup.sh install
  if [ $? -eq 0 ]; then
    setup_success $REDIS
    cd $CUR_DIR
  else
    return 1
  fi
}

check_install() {
  local MODULE=$1
  local MODULE_SETUP_BEGIN=$2
  local MODULE_SETUP_SUCCESS=$3
  if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 1 ]; then
    echo "$MODULE has installed, skip check..."
    return 2
  else
    if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 0 ]; then
      echo "Warning: $MODULE has installed before, but failed by some reason, check/build again?(Y/N)"
      while read input
      do
        if [ $input = "Y" ] || [ $input = "y" ]; then
          return 0
        elif [ $input = "N" ] || [ $input = "n" ]; then
          return 1
        else
          echo "unknown input, try again please, check/build again?(Y/N)."
          continue
        fi
      done
    fi
  fi
  return 0
}

check_env() {
  local MODULE=$1
  echo "start to check $MODULE..."
  check_$MODULE
  if [ $? -eq 0 ]; then
    echo "check $MODULE successed."
  else
    echo "Error: check $MODULE failed, stop install."
    exit 1
  fi
}

check_module() {
  local MODULE=$1
  local MODULE_SETUP_BEGIN=$2
  local MODULE_SETUP_SUCCESS=$3
  check_install $MODULE $MODULE_SETUP_BEGIN $MODULE_SETUP_SUCCESS
  RET=$?
  if [ $RET -eq 0 ]; then
    check_env $MODULE
  elif [ $RET -eq 1 ]; then
    return 1
  fi
  return 0
}

check_all() {
  get_setup_process

  #redis
  check_module $REDIS $REDIS_SETUP_BEGIN $REDIS_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  return 1

  #mysql
  check_module $MYSQL $MYSQL_SETUP_BEGIN $MYSQL_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #nginx
  check_module $NGINX $NGINX_SETUP_BEGIN $NGINX_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #php
  check_module $PHP $PHP_SETUP_BEGIN $PHP_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #jdk
  check_module $JDK $JDK_SETUP_BEGIN $JDK_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_web
  check_module $IM_WEB $IM_WEB_SETUP_BEGIN $IM_WEB_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_server
  check_module $IM_SERVER $IM_SERVER_SETUP_BEGIN $IM_SERVER_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_db_proxy
  check_module $IM_DB_PROXY $IM_DB_PROXY_SETUP_BEGIN $IM_DB_PROXY_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  echo "Check TeamTalk successed, and you can install TeamTalk now."
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

build_module() {
  local MODULE=$1
  local MODULE_SETUP_BEGIN=$2
  local MODULE_SETUP_SUCCESS=$3
  if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 1 ]; then
    echo "$MODULE has installed, skip build..."
  else
    echo "start to build $MODULE..."
    build_$MODULE
    if [ $? -eq 0 ]; then
      echo "build $MODULE successed."
    else
      echo "Error: build $MODULE failed, stop install."
      return 1
    fi
  fi
}

build_all() {
  #clean_yum
  #yum -y install yum
  #if [ $? -eq 0 ]; then
  #  echo "update yum successed."
  #else
  #  echo "update yum failed."
  #  exit 1
  #fi

  #redis
  build_module $REDIS $REDIS_SETUP_BEGIN $REDIS_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  return 1

  #mysql 
  build_module $MYSQL $MYSQL_SETUP_BEGIN $MYSQL_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #nginx
  build_module $NGINX $NGINX_SETUP_BEGIN $NGINX_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #php
  build_module $PHP $PHP_SETUP_BEGIN $PHP_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #jdk
  build_module $JDK $JDK_SETUP_BEGIN $JDK_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_web
  build_module $IM_WEB $IM_WEB_SETUP_BEGIN $IM_WEB_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_server
  build_module $IM_SERVER $IM_SERVER_SETUP_BEGIN $IM_SERVER_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi

  #im_db_proxy
  build_module $IM_DB_PROXY $IM_DB_PROXY_SETUP_BEGIN $IM_DB_PROXY_SETUP_SUCCESS
  if [ $? -eq 1 ]; then
    exit 1
  fi
}

print_usage() {
  echo "Usage: "
  echo "$0 check ---- to check prerequisit"
  echo "$0 install ---- to check and run script"
}

case $1 in
  check)
    ensure_root
    ensure_ubuntu
    initialize
    check_all
    ;;
  install)
    ensure_root
    ensure_ubuntu
    initialize
    check_all
    build_all
    ;;
  *)
    print_usage
    ;;
esac



