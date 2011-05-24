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
	OptArg=

	case $arg in
	-soname)  arg="-h" ;;
	-soname=*) OptArg="${arg#-soname=}"; arg="-h" ;;
	--version-script=*) continue ;; # ignore. this only make troubles!
	esac

	Args="$Args '$arg'"
	[ -z "$OptArg" ] || Args="$Args '$OptArg'"
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

#
# WARNING: --script is the last here intentionally, since all library paths given
# in the file are added dependant to the position where the --script option appears
# on the command line. this means that if not given last, libraries from /opt/gcc...
# and /usr/lib will allways get linked in before any library from our prefix (which
# we *definitly* don't want...
#
# There is some nasty redirection trick here, which enables this script to remove
# dumb assertions from stderr without touching the rest.
#
exec 3>&1
eval "/opt/gcc.3.3/bin/ld $Args --script '$ScriptDir/$ScriptPlatform.$ScriptExt'" 2>&1 >&3 3>&- \
    | grep -v -E 'assertion fail .*/cofflink.c:5211' 3>&- 1>&2 2>/dev/null
_st=${PIPESTATUS[0]}
exec 3>&-

exit ${_st}

