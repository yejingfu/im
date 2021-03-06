#!/bin/bash

t=`date +%Y%m%d_%H%M%S`
#cp src/main/bin/* ./
ALLPROTS=($@)
#echo '@ ' ($@)
for port in ${ALLPROTS[@]}
do
	echo 'port: ' ${port}
	file="./${port}" 
	if [ -d "$file" ] ; then  
		if [ ! -d "backup" ] ; then 
			mkdir "backup" 
		fi
		bak="backup/${port}_${t}"
		mv $file $bak
	fi  
	mkdir $port
	cd $port
	cp ../*.jar ./
	cp ../*.properties ./
	cp ../run.sh ./
	sh run.sh $port
	cd ..

done
