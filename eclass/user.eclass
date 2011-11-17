# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/user.eclass,v 1.10 2011/11/04 13:08:23 naota Exp $

# @ECLASS: user.eclass
# @MAINTAINER:
# base-system@gentoo.org (Linux)
# Joe Jezak <josejx@gmail.com> (OS X)
# usata@gentoo.org (OS X)
# Aaron Walker <ka0ttic@gentoo.org> (FreeBSD)
# @BLURB: user management in ebuilds
# @DESCRIPTION:
# The user eclass contains a suite of functions that allow ebuilds
# to quickly make sure users in the installed system are sane.

# @FUNCTION: _assert_pkg_ebuild_phase
# @INTERNAL
# @USAGE: <calling func name>
_assert_pkg_ebuild_phase() {
	case ${EBUILD_PHASE} in
	unpack|prepare|configure|compile|test|install)
		eerror "'$1()' called from '${EBUILD_PHASE}()' which is not a pkg_* function."
		eerror "Package fails at QA and at life.  Please file a bug."
		die "Bad package!  $1 is only for use in pkg_* functions!"
	esac
}

# @FUNCTION: egetent
# @USAGE: <database> <key>
# @DESCRIPTION:
# Small wrapper for getent (Linux), nidump (< Mac OS X 10.5),
# dscl (Mac OS X 10.5), and pw (FreeBSD) used in enewuser()/enewgroup().
#
# Supported databases: group passwd
egetent() {
	local db=$1 key=$2

	[[ $# -ge 3 ]] && die "usage: egetent <database> <key>"

	case ${db} in
	passwd|group) ;;
	*) die "sorry, database '${db}' not yet supported; file a bug" ;;
	esac

	case ${CHOST} in
	*-darwin[678])
		case ${key} in
		*[!0-9]*) # Non numeric
			nidump ${db} . | awk -F: "(\$1 ~ /^${key}\$/) {print;exit;}"
			;;
		*)	# Numeric
			nidump ${db} . | awk -F: "(\$3 == ${key}) {print;exit;}"
			;;
		esac
		;;
	*-darwin*)
		local mykey
		case ${db} in
		passwd) db="Users"  mykey="UniqueID" ;;
		group)  db="Groups" mykey="PrimaryGroupID" ;;
		esac

		case ${key} in
		*[!0-9]*) # Non numeric
			dscl . -read /${db}/${key} 2>/dev/null |grep RecordName
			;;
		*)	# Numeric
			dscl . -search /${db} ${mykey} ${key} 2>/dev/null
			;;
		esac
		;;
	*-freebsd*|*-dragonfly*)
		case ${db} in
		passwd) db="user" ;;
		*) ;;
		esac

		# lookup by uid/gid
		local opts
		if [[ ${key} == [[:digit:]]* ]] ; then
			[[ ${db} == "user" ]] && opts="-u" || opts="-g"
		fi

		pw show ${db} ${opts} "${key}" -q
		;;
	*-netbsd*|*-openbsd*)
		grep "${key}:\*:" /etc/${db}
		;;
	*)
		# ignore output if nscd doesn't exist, or we're not running as root
		nscd -i "${db}" 2>/dev/null
		getent "${db}" "${key}"
		;;
	esac
}

# @FUNCTION: enewuser
# @USAGE: <user> [uid] [shell] [homedir] [groups]
# @DESCRIPTION:
# Same as enewgroup, you are not required to understand how to properly add
# a user to the system.  The only required parameter is the username.
# Default uid is (pass -1 for this) next available, default shell is
# /bin/false, default homedir is /dev/null, and there are no default groups.
enewuser() {
	_assert_pkg_ebuild_phase enewuser

	# get the username
	local euser=$1; shift
	if [[ -z ${euser} ]] ; then
		eerror "No username specified !"
		die "Cannot call enewuser without a username"
	fi

	# in Prefix Portage, we may be unprivileged, such that we can't handle this
	rootuid=$(python -c 'from portage.const import rootuid; print rootuid')
	if [[ ${rootuid} != 0 ]] ; then
		ewarn "'enewuser()' disabled in Prefixed Portage with non-root user"
		return 0
	fi

	# lets see if the username already exists
	if [[ -n $(egetent passwd "${euser}") ]] ; then
		return 0
	fi
	einfo "Adding user '${euser}' to your system ..."

	# options to pass to useradd
	local opts=

	# handle uid
	local euid=$1; shift
	if [[ -n ${euid} && ${euid} != -1 ]] ; then
		if [[ ${euid} -gt 0 ]] ; then
			if [[ -n $(egetent passwd ${euid}) ]] ; then
				euid="next"
			fi
		else
			eerror "Userid given but is not greater than 0 !"
			die "${euid} is not a valid UID"
		fi
	else
		euid="next"
	fi
	if [[ ${euid} == "next" ]] ; then
		for ((euid = 101; euid <= 999; euid++)); do
			[[ -z $(egetent passwd ${euid}) ]] && break
		done
	fi
	opts+=" -u ${euid}"
	einfo " - Userid: ${euid}"

	# handle shell
	local eshell=$1; shift
	if [[ ! -z ${eshell} ]] && [[ ${eshell} != "-1" ]] ; then
		if [[ ! -e ${EROOT}${eshell} ]] ; then
			eerror "A shell was specified but it does not exist !"
			die "${eshell} does not exist in ${EROOT}"
		fi
		if [[ ${eshell} == */false || ${eshell} == */nologin ]] ; then
			eerror "Do not specify ${eshell} yourself, use -1"
			die "Pass '-1' as the shell parameter"
		fi
	else
		for shell in /sbin/nologin /usr/sbin/nologin /bin/false /usr/bin/false /dev/null ; do
			[[ -x ${ROOT}${shell} ]] && break
		done

		if [[ ${shell} == "/dev/null" ]] ; then
			eerror "Unable to identify the shell to use, proceeding with userland default."
			case ${USERLAND} in
				GNU) shell="/bin/false" ;;
				BSD) shell="/sbin/nologin" ;;
				Darwin) shell="/usr/sbin/nologin" ;;
				*) die "Unable to identify the default shell for userland ${USERLAND}"
			esac
		fi

		eshell=${shell}
	fi
	einfo " - Shell: ${eshell}"
	opts+=" -s ${eshell}"

	# handle homedir
	local ehome=$1; shift
	if [[ -z ${ehome} ]] || [[ ${ehome} == "-1" ]] ; then
		ehome="/dev/null"
	fi
	einfo " - Home: ${ehome}"
	opts+=" -d ${ehome}"

	# handle groups
	local egroups=$1; shift
	if [[ ! -z ${egroups} ]] ; then
		local oldifs=${IFS}
		local defgroup="" exgroups=""

		export IFS=","
		for g in ${egroups} ; do
			export IFS=${oldifs}
			if [[ -z $(egetent group "${g}") ]] ; then
				eerror "You must add group ${g} to the system first"
				die "${g} is not a valid GID"
			fi
			if [[ -z ${defgroup} ]] ; then
				defgroup=${g}
			else
				exgroups="${exgroups},${g}"
			fi
			export IFS=","
		done
		export IFS=${oldifs}

		opts+=" -g ${defgroup}"
		if [[ ! -z ${exgroups} ]] ; then
			opts+=" -G ${exgroups:1}"
		fi
	else
		egroups="(none)"
	fi
	einfo " - Groups: ${egroups}"

	# handle extra args
	if [[ $# -gt 0 ]] ; then
		die "extra arguments no longer supported; please file a bug"
	else
		set -- -c "added by portage for ${PN}"
		einfo " - Extra: $@"
	fi

	# add the user
	local oldsandbox=${SANDBOX_ON}
	export SANDBOX_ON="0"
	case ${CHOST} in
	*-darwin*)
		### Make the user
		dscl . create /users/${euser} uid ${euid}
		dscl . create /users/${euser} shell ${eshell}
		dscl . create /users/${euser} home ${ehome}
		dscl . create /users/${euser} realname "added by portage for ${PN}"
		### Add the user to the groups specified
		local oldifs=${IFS}
		export IFS=","
		for g in ${egroups} ; do
			dscl . merge /groups/${g} users ${euser}
		done
		export IFS=${oldifs}
		;;

	*-freebsd*|*-dragonfly*)
		pw useradd ${euser} ${opts} "$@" || die
		;;

	*-netbsd*)
		useradd ${opts} ${euser} "$@" || die
		;;

	*-openbsd*)
		# all ops the same, except the -g vs -g/-G ...
		useradd -u ${euid} -s ${eshell} \
			-d ${ehome} -g ${egroups} "$@" ${euser} || die
		;;

	*)
		useradd -r ${opts} "$@" ${euser} || die
		;;
	esac

	if [[ ! -e ${EROOT}/${ehome} ]] ; then
		einfo " - Creating ${ehome} in ${EROOT}"
		mkdir -p "${EROOT}/${ehome}"
		chown ${euser} "${EROOT}/${ehome}"
		chmod 755 "${EROOT}/${ehome}"
	fi

	export SANDBOX_ON=${oldsandbox}
}

# @FUNCTION: enewgroup
# @USAGE: <group> [gid]
# @DESCRIPTION:
# This function does not require you to understand how to properly add a
# group to the system.  Just give it a group name to add and enewgroup will
# do the rest.  You may specify the gid for the group or allow the group to
# allocate the next available one.
enewgroup() {
	_assert_pkg_ebuild_phase enewgroup

	# get the group
	local egroup="$1"; shift
	if [ -z "${egroup}" ]
	then
		eerror "No group specified !"
		die "Cannot call enewgroup without a group"
	fi

	# in Prefix Portage, we may be unprivileged, such that we can't handle this
	rootuid=$(python -c 'from portage.const import rootuid; print rootuid')
	if [[ ${rootuid} != 0 ]] ; then
		ewarn "'enewgroup()' disabled in Prefixed Portage with non root user"
		return 0
	fi

	# see if group already exists
	if [[ -n $(egetent group "${egroup}") ]]; then
		return 0
	fi
	einfo "Adding group '${egroup}' to your system ..."

	# options to pass to useradd
	local opts=

	# handle gid
	local egid="$1"; shift
	if [ ! -z "${egid}" ]
	then
		if [ "${egid}" -gt 0 ]
		then
			if [ -z "`egetent group ${egid}`" ]
			then
				if [[ "${CHOST}" == *-darwin* ]]; then
					opts+=" ${egid}"
				else
					opts+=" -g ${egid}"
				fi
			else
				egid="next available; requested gid taken"
			fi
		else
			eerror "Groupid given but is not greater than 0 !"
			die "${egid} is not a valid GID"
		fi
	else
		egid="next available"
	fi
	einfo " - Groupid: ${egid}"

	# handle extra
	if [ $# -gt 0 ] ; then
		die "extra arguments no longer supported; please file a bug"
	fi

	# add the group
	local oldsandbox="${SANDBOX_ON}"
	export SANDBOX_ON="0"
	case ${CHOST} in
	*-darwin*)
		# If we need the next available
		case ${egid} in
		*[!0-9]*) # Non numeric
			for ((egid = 101; egid <= 999; egid++)); do
				[[ -z $(egetent group ${egid}) ]] && break
			done
		esac
		dscl . create /groups/${egroup} gid ${egid}
		dscl . create /groups/${egroup} passwd '*'
		;;

	*-freebsd*|*-dragonfly*)
		case ${egid} in
			*[!0-9]*) # Non numeric
				for ((egid = 101; egid <= 999; egid++)); do
					[[ -z $(egetent group ${egid}) ]] && break
				done
		esac
		pw groupadd ${egroup} -g ${egid} || die
		;;

	*-netbsd*)
		case ${egid} in
		*[!0-9]*) # Non numeric
			for ((egid = 101; egid <= 999; egid++)); do
				[[ -z $(egetent group ${egid}) ]] && break
			done
		esac
		groupadd -g ${egid} ${egroup} || die
		;;

	*)
		# We specify -r so that we get a GID in the system range from login.defs
		groupadd -r ${opts} ${egroup} || die
		;;
	esac
	export SANDBOX_ON="${oldsandbox}"
}

# @FUNCTION: egethome
# @USAGE: <user>
# @DESCRIPTION:
# Gets the home directory for the specified user.
egethome() {
	local pos

	[[ $# -eq 1 ]] || die "usage: egethome <user>"

	case ${CHOST} in
	*-darwin*|*-freebsd*|*-dragonfly*)
		pos=9
		;;
	*)	# Linux, NetBSD, OpenBSD, etc...
		pos=6
		;;
	esac

	egetent passwd $1 | cut -d: -f${pos}
}

# @FUNCTION: egetshell
# @USAGE: <user>
# @DESCRIPTION:
# Gets the shell for the specified user.
egetshell() {
	local pos

	[[ $# -eq 1 ]] || die "usage: egetshell <user>"

	case ${CHOST} in
	*-darwin*|*-freebsd*|*-dragonfly*)
		pos=10
		;;
	*)	# Linux, NetBSD, OpenBSD, etc...
		pos=7
		;;
	esac

	egetent passwd "$1" | cut -d: -f${pos}
}
