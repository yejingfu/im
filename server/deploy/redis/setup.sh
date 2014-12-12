# setup redis
export MAKE=make
REDIS=redis-2.8.13
REDIS_DOWNLOAD_PATH=http://download.redis.io/releases/$REDIS.tar.gz
REDIS_CONF_PATH=/usr/local/etc
REDIS_CONF=redis.conf
REDIS_SERVER_PATH=/usr/local/bin
REDIS_SERVER=redis-server

print_hello(){
  echo "==========================================="
  echo "$1 redis"
  echo "==========================================="
}

ensure_root() {
  if [ $(id -u) != "0" ]; then
    echo "You must run the script as root user"
    exit 1
  fi
}

ensure_ubuntu() {
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
  ps -ef | grep -v 'grep' | grep redis-server
  if [ $? -eq 0 ]; then
    echo "Error: redis is running."
    exit 1
  fi
}

download() {
  if [ -f "$1" ]; then
    echo "$1 existed."
  else
    echo "$1 not existed, begin to download..."
    wget $2
    if [ $? -eq 0 ]; then
      echo "download $1 successed"
    else
      echo "Error: download $1 failed"
      return 1
    fi
  fi
  return 0
}

run_redis() {
  PROCESS=$(pgrep redis)
  if [ -z "$PROCESS" ]; then 
    echo "no redis is running..." 
  else 
    echo "Warning: redis is running"
    return 0
  fi

  cd conf/
  if [ -f "$REDIS_CONF" ]; then
    set -x
    cp -f $REDIS_CONF $REDIS_CONF_PATH/
    set +x
    cd ../
  else
    cd ../
    echo "Error: $REDIS_CONF not existed."
    return 1
  fi

  $REDIS_SERVER_PATH/$REDIS_SERVER $REDIS_CONF_PATH/$REDIS_CONF
  if [ $? -eq 0 ]; then
    echo "start redis successed."
  else
    echo "Error: start redis failed."
    return 1
  fi
}

build_redis() {
  download $REDIS.tar.gz $REDIS_DOWNLOAD_PATH
  if [ $? -eq 1 ]; then
    return 1
  fi

  tar xzf $REDIS.tar.gz
  cd $REDIS
  $MAKE
  if [ $? -eq 0 ]; then
    echo "make redis successed"
  else
    echo "Error: make redis failed"
    return 1
  fi

  $MAKE install
  if [ $? -eq 0 ]; then
    echo "install redis successed"
  else
    echo "Error: install redis failed"
  return 1
  fi
  cd ..
}

build_all() {
  build_redis
  if [ $? -eq 0 ]; then
    echo "build redis successed."
  else
    echo "Error: build redis failed."
    exit 1
  fi

  run_redis
  if [ $? -eq 0 ]; then
    echo "run redis successed."
  else
    echo "Error: run redis failed."
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
    ensure_root
    ensure_ubuntu
    check_run
    ;;
  install)
    print_hello $1
    ensure_root
    ensure_ubuntu
    check_run
    build_all
    ;;
  *)
    print_help
    ;;
esac

