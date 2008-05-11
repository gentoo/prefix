#!/bin/sh

case $1 in
	-dc)
		shift
		cat "$@" | lzmadec
		;;
	-d)
		shift
		lzmadec
		;;
	*)
		(
		echo "You've built lzma-utils without C++ support."
		echo "If you want lzma support, rebuild with C++ support."
		) 1>&2
		exit 1
		;;
esac
