#!/bin/sh

# Wrapper for interix to avoid /usr/local/*. This is done
# by using our own linker scripts. These scripts are copied
# over from interix' gcc 3.3 and modified to not include
# /usr/local/lib for library search. Still we have to tell
# ld to use those scripts....

ScriptDir=@SCRIPTDIR@
ScriptPlatform=i386pe_posix
ScriptExt=x

Opt_Ur=no
Opt_r=no
Opt_N=no
Opt_n=no
Opt_shared=no
Args=

for arg in "$@"; do
	case $arg in
	-Ur)      Opt_Ur=yes ;;
	-r)       Opt_r=yes ;;
	-N)       Opt_N=yes ;;
	-n)       Opt_n=yes ;;
	--shared) Opt_shared=yes ;;
	esac

	# manpages states '-soname', but '-h' seems to work better !?
	case $arg in
	-soname)  arg="-h" ;;
	esac

	Args="$Args '$arg'"
done

if [ $Opt_Ur = "yes" ]; then
	ScriptExt=xu
elif [ $Opt_r = "yes" ]; then
	ScriptExt=xr
elif [ $Opt_N = "yes" ]; then
	ScriptExt=xbn
elif [ $Opt_n = "yes" ]; then
	ScriptExt=xn
elif [ $Opt_shared = "yes" ]; then
	ScriptExt=xs
fi

eval "exec /opt/gcc.3.3/bin/ld --script '$ScriptDir/$ScriptPlatform.$ScriptExt' $Args"

