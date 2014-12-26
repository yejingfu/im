#!/bin/bash

build_server(){
	echo "build server: " $1
	what=$1
	script=package${what}.sh
	pack=businesspack
	./${script}

	mkdir -p businesspack

	cp ./target/*.jar ./${pack}
	cp ./src/main/resources/*.properties ./${pack}
	cp ./run.sh ./startup.sh ./talkshutdown.sh ./${pack}
	tar zcvf ${pack}.tar.gz ./${pack}/*

	cp ${pack}.tar.gz ../../deploy/im_db_proxy/
}

print_help() {
	echo "Usage: "
	echo "  $0 [dev|product]  -- build specific server"
}

case $1 in
	dev)
	    build_server $1
		;;
	product)
	    build_server $1
		;;

	*)
		print_help
		;;
esac
