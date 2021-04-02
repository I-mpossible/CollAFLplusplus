#!/bin/sh

case $# in
	1)
		cd /home/vmuser/CollAFLplusplus
		sed -i "s/#define MAP_SIZE_POW2 .*/#define MAP_SIZE_POW2 $1/g" config.h
		sed -i "s/#define MAP_SIZE_POW2 .*/#define MAP_SIZE_POW2 $1/g" include/config.h
		make clean
		make source-only -j8
		cd /home/vmuser/original/CollAFLplusplus
		sed -i "s/#define MAP_SIZE_POW2 .*/#define MAP_SIZE_POW2 $1/g" include/config.h
		make clean
		make source-only -j8
	;;
	*)
		echo "usage ./chmap.sh MAP_SIZE_POW2"
	;;
esac

