#!/bin/sh
# This script symlinks /usr/bin/lua, /usr/bin/luac to the appropiate Lua binarys
# indicated by WANT_LUA
# Example usage: WANT_LUA="5.0" lua-config

if [[ -n ${WANT_LUA} ]]; then
	if [[ -f /usr/bin/lua-${WANT_LUA} && -f /usr/bin/luac-${WANT_LUA} ]]; then
		if [[ ! -f /usr/bin/lua && ! -f /usr/bin/luac ]]; then
			ln -sf /usr/bin/lua-${WANT_LUA} /usr/bin/lua
			ln -sf /usr/bin/luac-${WANT_LUA} /usr/bin/luac
		else
			echo "Not going to overwrite regular files. Either lua or luac are regular files."
		fi
	else
		echo "The lua version you wanted (${WANT_LUA}) is not avaible. Make sure to specify the version string as X.y where X and y are major and minor version numbers"
	fi
else
	echo "Please set the WANT_LUA enviroment variable to the lua version you wish to use, eg: WANT_LUA='5.1'"
fi
