im
==

## Deploy

### installation

#### OpenSSL (LibSSL)

    # apt-get install libssl-dev

#### Percona (MySQL)

    # apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
    ## edit /etc/apt/sources.list by adding the section
    deb http://repo.percona.com/apt trusty main
    deb-src http://repo.percona.com/apt trusty main
    # apt-get update
    # apt-get install percona-server-server-5.5 percona-server-client-5.5

    ## check if it is running:
    $ ps -ef | grep -v 'grep' | grep mysqld

    ## start server
    # service mysql start
    ## stop server
    # service mysql stop

    ## workbench -- client 
    ## install from Ubuntu soteware center: "mysql-workbench"

#### PHP5-FPM

    # apt-get install php5-fpm php5-cli php5-mysql -y
    
    ## install json for php
    # apt-get install php5-json

    ## install php5 dev, so that phpize can be used.
    # apt-get install php5-dev
    
    ## let php-cli use the same ini configuration of php-fpm
    # cd /etc/php5/cli
    # mv php.ini php.ini.org    ## backup
    # ln -s ../fpm/php.ini
    ## make sure the php server is listening on right socket (see /etc/php5/fpm/pool.d/www.conf)
        listen = /var/run/php-fpm-sock
    
    ## nginx reverse proxy setting ( see : /etc/ngnix/conf.d/my.conf )
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_hide_header X-Powered-By;
        }
    ## restart nginix and php-fpm
    # service ngnix restart
    # service php5-fpm restart
    
    ## write php file for testing (index.php)
        <?php
          phpinfo();
        ?>

#### xdebug

* install

follow this [page](http://xdebug.org/docs/install) to install xdebug

    download xdebug-2.2.5.tgz  // or git clone git://github.com/xdebug/xdebug.git
    $ tar -xzf xdebug-2.2.5.tgz
    $ cd xdebug-2.2.5
    $ phpize
    $ ./configure --enable-xdebug
    $ make
    $ sudo make install
    
* setup

follow this [page](http://hoarn.blog.51cto.com/1642678/1184441) to setup xdebug.

    add settings into php.ini, like:
    zend_extension="/usr/lib/php5/20121212/xdebug.so"
    ...
    make sure the error_log functionalities are enabled in the php.ini
    $ sudo service php5-fpm restart

    

#### Java (DB Proxy)

* install java (the easy way)

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
    sudo apt-get install oracle-java7-installer

* build java source code by maven

    ## install maven
    # apt-get install maven
    
#### File server

* issue 1: conflict on port 8500, please change port to other port like port 8600

