How to build the server
===========================

### build middleware service (cpp based)

``` bash
$ cd cpp/src
$ ./build.sh version 0.0.1
```

The middleware component would be packaged and copied to `../deploy/im_server/`.

### build business component (java based)

``` bash
$ cd java
$ ./build.sh [dev | product]
```

The java based business component would be packaged and copied to `../deploy/im_db_proxy/`.

