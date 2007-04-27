# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/eutils.eclass,v 1.279 2007/04/25 09:14:35 carlo Exp $
#
# This eclass is for general purpose functions that most ebuilds
# have to implement themselves.
#
# NB:  If you add anything, please comment it!
#
# Maintainer: see each individual function, base-system@gentoo.org as default

inherit multilib portability

DESCRIPTION="Based on the ${ECLASS} eclass"

# Wait for the supplied number of seconds. If no argument is supplied, defaults
# to five seconds. If the EPAUSE_IGNORE env var is set, don't wait. If we're not
# outputting to a terminal, don't wait. For compatability purposes, the argument
# must be an integer greater than zero.
# Bug 62950, Ciaran McCreesh <ciaranm@gentoo.org> (05 Sep 2004)
epause() {
	[[ -z ${EPAUSE_IGNORE} ]] && sleep ${1:-5}
}

# Beep the specified number of times (defaults to five). If our output
# is not a terminal, don't beep. If the EBEEP_IGNORE env var is set,
# don't beep.
# Bug 62950, Ciaran McCreesh <ciaranm@gentoo.org> (05 Sep 2004)
ebeep() {
	local n
	if [[ -z ${EBEEP_IGNORE} ]] ; then
		for ((n=1 ; n <= ${1:-5} ; n++)) ; do
			echo -ne "\a"
			sleep 0.1 &>/dev/null ; sleep 0,1 &>/dev/null
			echo -ne "\a"
			sleep 1
		done
	fi
}

# This function generate linker scripts in /usr/lib for dynamic
# libs in /lib.	 This is to fix linking problems when you have
# the .so in /lib, and the .a in /usr/lib.	What happens is that
# in some cases when linking dynamic, the .a in /usr/lib is used
# instead of the .so in /lib due to gcc/libtool tweaking ld's
# library search path.	This cause many builds to fail.
# See bug #4411 for more info.
#
# To use, simply call:
#
#	gen_usr_ldscript libfoo.so
#
# Note that you should in general use the unversioned name of
# the library, as ldconfig should usually update it correctly
# to point to the latest version of the library present.
#
# <azarah@gentoo.org> (26 Oct 2002)
#
gen_usr_ldscript() {
	if [[ $(type -t _tc_gen_usr_ldscript) == "function" ]] ; then
		_tc_gen_usr_ldscript "$@"
		return $?
	fi

	ewarn "QA Notice: Please upgrade your ebuild to use toolchain-funcs"
	ewarn "QA Notice:  rather than gen_usr_ldscript() from eutils"

	local lib libdir=$(get_libdir)
	# Just make sure it exists
	dodir /usr/${libdir}

	for lib in "${@}" ; do
		cat > "${ED}/usr/${libdir}/${lib}" <<-END_LDSCRIPT
		/* GNU ld script
		   Since Gentoo has critical dynamic libraries
		   in /lib, and the static versions in /usr/lib,
		   we need to have a "fake" dynamic lib in /usr/lib,
		   otherwise we run into linking problems.

		   See bug http://bugs.gentoo.org/4411 for more info.
		 */
		GROUP ( /${libdir}/${lib} )
		END_LDSCRIPT
		fperms a+x "/usr/${libdir}/${lib}" || die "could not change perms on ${lib}"
	done
}


# Default directory where patches are located
EPATCH_SOURCE="${WORKDIR}/patch"
# Default extension for patches
EPATCH_SUFFIX="patch.bz2"
# Default options for patch
# Set -g0 to keep RCS, ClearCase, Perforce and SCCS happy. Bug #24571
# Set --no-backup-if-mismatch so we don't leave '.orig' files behind.
# Set -E to automatically remove empty files.
EPATCH_OPTS="-g0 -E --no-backup-if-mismatch"
# List of patches not to apply.	 Not this is only file names,
# and not the full path ..
EPATCH_EXCLUDE=""
# Change the printed message for a single patch.
EPATCH_SINGLE_MSG=""
# Change the printed message for multiple patches.
EPATCH_MULTI_MSG="Applying various patches (bugfixes/updates) ..."
# Force applying bulk patches even if not following the style:
#
#	??_${ARCH}_foo.${EPATCH_SUFFIX}
#
EPATCH_FORCE="no"

# This function is for bulk patching, or in theory for just one
# or two patches.
#
# It should work with .bz2, .gz, .zip and plain text patches.
# Currently all patches should be the same format.
#
# You do not have to specify '-p' option to patch, as it will
# try with -p0 to -p5 until it succeed, or fail at -p5.
#
# Above EPATCH_* variables can be used to control various defaults,
# bug they should be left as is to ensure an ebuild can rely on
# them for.
#
# Patches are applied in current directory.
#
# Bulk Patches should preferibly have the form of:
#
#	??_${ARCH}_foo.${EPATCH_SUFFIX}
#
# For example:
#
#	01_all_misc-fix.patch.bz2
#	02_sparc_another-fix.patch.bz2
#
# This ensures that there are a set order, and you can have ARCH
# specific patches.
#
# If you however give an argument to epatch(), it will treat it as a
# single patch that need to be applied if its a file.  If on the other
# hand its a directory, it will set EPATCH_SOURCE to this.
#
# <azarah@gentoo.org> (10 Nov 2002)
#
epatch() {
	_epatch_draw_line() {
		[[ -z $1 ]] && set "$(printf "%65s" '')"
		echo "${1//?/=}"
	}
	_epatch_assert() { local _pipestatus=${PIPESTATUS[*]}; [[ ${_pipestatus// /} -eq 0 ]] ; }
	local PIPE_CMD=""
	local STDERR_TARGET="${T}/$$.out"
	local PATCH_TARGET="${T}/$$.patch"
	local PATCH_SUFFIX=""
	local SINGLE_PATCH="no"
	local x=""

	unset P4CONFIG P4PORT P4USER # keep perforce at bay #56402

	if [ "$#" -gt 1 ]
	then
		local m=""
		for m in "$@" ; do
			epatch "${m}"
		done
		return 0
	fi

	if [ -n "$1" -a -f "$1" ]
	then
		SINGLE_PATCH="yes"

		local EPATCH_SOURCE="$1"
		local EPATCH_SUFFIX="${1##*\.}"

	elif [ -n "$1" -a -d "$1" ]
	then
		# Allow no extension if EPATCH_FORCE=yes ... used by vim for example ...
		if [ "${EPATCH_FORCE}" = "yes" ] && [ -z "${EPATCH_SUFFIX}" ]
		then
			local EPATCH_SOURCE="$1/*"
		else
			local EPATCH_SOURCE="$1/*.${EPATCH_SUFFIX}"
		fi
	else
		if [ ! -d ${EPATCH_SOURCE} ] || [ -n "$1" ]
		then
			if [ -n "$1" -a "${EPATCH_SOURCE}" = "${WORKDIR}/patch" ]
			then
				EPATCH_SOURCE="$1"
			fi

			echo
			eerror "Cannot find \$EPATCH_SOURCE!  Value for \$EPATCH_SOURCE is:"
			eerror
			eerror "  ${EPATCH_SOURCE}"
			eerror "  ( ${EPATCH_SOURCE##*/} )"
			echo
			die "Cannot find \$EPATCH_SOURCE!"
		fi

		local EPATCH_SOURCE="${EPATCH_SOURCE}/*.${EPATCH_SUFFIX}"
	fi

	case ${EPATCH_SUFFIX##*\.} in
		bz2)
			PIPE_CMD="bzip2 -dc"
			PATCH_SUFFIX="bz2"
			;;
		gz|Z|z)
			PIPE_CMD="gzip -dc"
			PATCH_SUFFIX="gz"
			;;
		ZIP|zip)
			PIPE_CMD="unzip -p"
			PATCH_SUFFIX="zip"
			;;
		*)
			PIPE_CMD="cat"
			PATCH_SUFFIX="patch"
			;;
	esac

	if [ "${SINGLE_PATCH}" = "no" ]
	then
		einfo "${EPATCH_MULTI_MSG}"
	fi
	for x in ${EPATCH_SOURCE}
	do
		# New ARCH dependant patch naming scheme ...
		#
		#	???_arch_foo.patch
		#
		if [ -f ${x} ] && \
		   ([ "${SINGLE_PATCH}" = "yes" -o "${x/_all_}" != "${x}" -o "${x/_${ARCH}_}" != "${x}" ] || \
			[ "${EPATCH_FORCE}" = "yes" ])
		then
			local count=0
			local popts="${EPATCH_OPTS}"
			local patchname=${x##*/}

			if [ -n "${EPATCH_EXCLUDE}" ]
			then
				if [ "${EPATCH_EXCLUDE/${patchname}}" != "${EPATCH_EXCLUDE}" ]
				then
					continue
				fi
			fi

			if [ "${SINGLE_PATCH}" = "yes" ]
			then
				if [ -n "${EPATCH_SINGLE_MSG}" ]
				then
					einfo "${EPATCH_SINGLE_MSG}"
				else
					einfo "Applying ${patchname} ..."
				fi
			else
				einfo "  ${patchname} ..."
			fi

			echo "***** ${patchname} *****" > ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
			echo >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}

			# Allow for prefix to differ ... im lazy, so shoot me :/
			while [ "${count}" -lt 5 ]
			do
				# Generate some useful debug info ...
				_epatch_draw_line "***** ${patchname} *****" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
				echo >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}

				if [ "${PATCH_SUFFIX}" != "patch" ]
				then
					echo -n "PIPE_COMMAND:	" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
					echo "${PIPE_CMD} ${x} > ${PATCH_TARGET}" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
				else
					PATCH_TARGET="${x}"
				fi

				echo -n "PATCH COMMAND:	 " >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
				echo "patch -p${count} ${popts} < ${PATCH_TARGET}" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}

				echo >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
				_epatch_draw_line "***** ${patchname} *****" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}

				if [ "${PATCH_SUFFIX}" != "patch" ]
				then
					if ! (${PIPE_CMD} ${x} > ${PATCH_TARGET}) >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/} 2>&1
					then
						echo
						eerror "Could not extract patch!"
						#die "Could not extract patch!"
						count=5
						break
					fi
				fi

				if (cat ${PATCH_TARGET} | patch -p${count} ${popts} --dry-run -f ; _epatch_assert) >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/} 2>&1
				then
					_epatch_draw_line "***** ${patchname} *****" >	${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real
					echo >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real
					echo "ACTUALLY APPLYING ${patchname} ..." >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real
					echo >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real
					_epatch_draw_line "***** ${patchname} *****" >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real

					cat ${PATCH_TARGET} | patch -p${count} ${popts} >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real 2>&1
					_epatch_assert

					if [ "$?" -ne 0 ]
					then
						cat ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real >> ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}
						echo
						eerror "A dry-run of patch command succeeded, but actually"
						eerror "applying the patch failed!"
						#die "Real world sux compared to the dreamworld!"
						count=5
					fi

					rm -f ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}.real

					break
				fi

				count=$((count + 1))
			done

			if [ "${PATCH_SUFFIX}" != "patch" ]
			then
				rm -f ${PATCH_TARGET}
			fi

			if [ "${count}" -eq 5 ]
			then
				echo
				eerror "Failed Patch: ${patchname} !"
				eerror " ( ${PATCH_TARGET} )"
				eerror
				eerror "Include in your bugreport the contents of:"
				eerror
				eerror "  ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}"
				echo
				die "Failed Patch: ${patchname}!"
			fi

			rm -f ${STDERR_TARGET%/*}/${patchname}-${STDERR_TARGET##*/}

			eend 0
		fi
	done
	if [ "${SINGLE_PATCH}" = "no" ]
	then
		einfo "Done with patching"
	fi
}

# Cheap replacement for when debianutils (and thus mktemp)
# does not exist on the users system
# vapier@gentoo.org
#
# Takes just 1 optional parameter (the directory to create tmpfile in)
emktemp() {
	local exe="touch"
	[[ $1 == -d ]] && exe="mkdir" && shift
	local topdir=$1

	if [[ -z ${topdir} ]] ; then
		[[ -z ${T} ]] \
			&& topdir="/tmp" \
			|| topdir=${T}
	fi

	if [[ -z $(type -p mktemp) ]] ; then
		local tmp=/
		while [[ -e ${tmp} ]] ; do
			tmp=${topdir}/tmp.${RANDOM}.${RANDOM}.${RANDOM}
		done
		${exe} "${tmp}" || ${exe} -p "${tmp}"
		echo "${tmp}"
	else
		if [[ ${exe} == "touch" ]] ; then
			# for FreeBSD-mktemp, -t is the prefix
			# for GNU-mktemp, -t is the template
			# in eprefix, we might have USERLAND!=GNU, but GNU-mktemp,
			# and we will end up with empty tempfile names.
			#
			# OTOH, having tempfiles called tmp.XXXXXXXXXX.WSqcv4AI
			# in BSD will not be a problem.
			TMPDIR="${topdir}" mktemp -t tmp.XXXXXXXXXX
		else
			TMPDIR="${topdir}" mktemp -dt tmp.XXXXXXXXXX
		fi
	fi
}

# Small wrapper for getent (Linux), nidump (Mac OS X),
# and pw (FreeBSD) used in enewuser()/enewgroup()
# Joe Jezak <josejx@gmail.com> and usata@gentoo.org
# FBSD stuff: Aaron Walker <ka0ttic@gentoo.org>
#
# egetent(database, key)
egetent() {
	case ${CHOST} in
	*-darwin*)
		case "$2" in
		*[!0-9]*) # Non numeric
			nidump $1 . | awk -F":" "{ if (\$1 ~ /^$2$/) {print \$0;exit;} }"
			;;
		*)	# Numeric
			nidump $1 . | awk -F":" "{ if (\$3 == $2) {print \$0;exit;} }"
			;;
		esac
		;;
	*-freebsd*|*-dragonfly*)
		local opts action="user"
		[[ $1 == "passwd" ]] || action="group"

		# lookup by uid/gid
		if [[ $2 == [[:digit:]]* ]] ; then
			[[ ${action} == "user" ]] && opts="-u" || opts="-g"
		fi

		pw show ${action} ${opts} "$2" -q
		;;
	*-netbsd*|*-openbsd*)
		grep "$2:\*:" /etc/$1
		;;
	*)
		type -p nscd >& /dev/null && nscd -i "$1"
		getent "$1" "$2"
		;;
	esac
}

# Simplify/standardize adding users to the system
# vapier@gentoo.org
#
# enewuser(username, uid, shell, homedir, groups, extra options)
#
# Default values if you do not specify any:
# username:	REQUIRED !
# uid:		next available (see useradd(8))
#		note: pass -1 to get default behavior
# shell:	/bin/false
# homedir:	/dev/null
# groups:	none
# extra:	comment of 'added by portage for ${PN}'
enewuser() {
	# in prefix portage, we don't know how to handle this yet
	ewarn "'enewuser()' currently disabled in prefixed portage"
	return 0

	case ${EBUILD_PHASE} in
		unpack|compile|test|install)
		eerror "'enewuser()' called from '${EBUILD_PHASE}()' which is not a pkg_* function."
		eerror "Package fails at QA and at life.  Please file a bug."
		die "Bad package!  enewuser is only for use in pkg_* functions!"
	esac

	# get the username
	local euser=$1; shift
	if [[ -z ${euser} ]] ; then
		eerror "No username specified !"
		die "Cannot call enewuser without a username"
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
	opts="${opts} -u ${euid}"
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
			[[ -x ${EROOT}${shell} ]] && break
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
	opts="${opts} -s ${eshell}"

	# handle homedir
	local ehome=$1; shift
	if [[ -z ${ehome} ]] || [[ ${ehome} == "-1" ]] ; then
		ehome="/dev/null"
	fi
	einfo " - Home: ${ehome}"
	opts="${opts} -d ${ehome}"

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

		opts="${opts} -g ${defgroup}"
		if [[ ! -z ${exgroups} ]] ; then
			opts="${opts} -G ${exgroups:1}"
		fi
	else
		egroups="(none)"
	fi
	einfo " - Groups: ${egroups}"

	# handle extra and add the user
	local oldsandbox=${SANDBOX_ON}
	export SANDBOX_ON="0"
	case ${CHOST} in
	*-darwin*)
		### Make the user
		if [[ -z $@ ]] ; then
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
		else
			einfo "Extra options are not supported on Darwin yet"
			einfo "Please report the ebuild along with the info below"
			einfo "eextra: $@"
			die "Required function missing"
		fi
		;;
	*-freebsd*|*-dragonfly*)
		if [[ -z $@ ]] ; then
			pw useradd ${euser} ${opts} \
				-c "added by portage for ${PN}" \
				die "enewuser failed"
		else
			einfo " - Extra: $@"
			pw useradd ${euser} ${opts} \
				"$@" || die "enewuser failed"
		fi
		;;

	*-netbsd*)
		if [[ -z $@ ]] ; then
			useradd ${opts} ${euser} || die "enewuser failed"
		else
			einfo " - Extra: $@"
			useradd ${opts} ${euser} "$@" || die "enewuser failed"
		fi
		;;

	*-openbsd*)
		if [[ -z $@ ]] ; then
			useradd -u ${euid} -s ${eshell} \
				-d ${ehome} -c "Added by portage for ${PN}" \
				-g ${egroups} ${euser} || die "enewuser failed"
		else
			einfo " - Extra: $@"
			useradd -u ${euid} -s ${eshell} \
				-d ${ehome} -c "Added by portage for ${PN}" \
				-g ${egroups} ${euser} "$@" || die "enewuser failed"
		fi
		;;

	*)
		if [[ -z $@ ]] ; then
			useradd ${opts} ${euser} \
				-c "added by portage for ${PN}" \
				|| die "enewuser failed"
		else
			einfo " - Extra: $@"
			useradd ${opts} ${euser} "$@" \
				|| die "enewuser failed"
		fi
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

# Simplify/standardize adding groups to the system
# vapier@gentoo.org
#
# enewgroup(group, gid)
#
# Default values if you do not specify any:
# groupname:	REQUIRED !
# gid:		next available (see groupadd(8))
# extra:	none
enewgroup() {
	# in prefix portage, we don't know how to handle this yet
	ewarn "'enewgroup()' currently disabled in prefixed portage"
	return 0

	case ${EBUILD_PHASE} in
		unpack|compile|test|install)
		eerror "'enewgroup()' called from '${EBUILD_PHASE}()' which is not a pkg_* function."
		eerror "Package fails at QA and at life.  Please file a bug."
		die "Bad package!  enewgroup is only for use in pkg_* functions!"
	esac

	# get the group
	local egroup="$1"; shift
	if [ -z "${egroup}" ]
	then
		eerror "No group specified !"
		die "Cannot call enewgroup without a group"
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
					opts="${opts} ${egid}"
				else
					opts="${opts} -g ${egid}"
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
	local eextra="$@"
	opts="${opts} ${eextra}"

	# add the group
	local oldsandbox="${SANDBOX_ON}"
	export SANDBOX_ON="0"
	case ${CHOST} in
	*-darwin*)
		if [ ! -z "${eextra}" ];
		then
			einfo "Extra options are not supported on Darwin/OS X yet"
			einfo "Please report the ebuild along with the info below"
			einfo "eextra: ${eextra}"
			die "Required function missing"
		fi

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
		pw groupadd ${egroup} -g ${egid} || die "enewgroup failed"
		;;

	*-netbsd*)
		case ${egid} in
		*[!0-9]*) # Non numeric
			for ((egid = 101; egid <= 999; egid++)); do
				[[ -z $(egetent group ${egid}) ]] && break
			done
		esac
		groupadd -g ${egid} ${egroup} || die "enewgroup failed"
		;;

	*)
		groupadd ${opts} ${egroup} || die "enewgroup failed"
		;;
	esac
	export SANDBOX_ON="${oldsandbox}"
}

# Simple script to replace 'dos2unix' binaries
# vapier@gentoo.org
#
# edos2unix(file, <more files> ...)
edos2unix() {
	echo "$@" | xargs sed -i 's/\r$//'
}


##############################################################
# START: Handle .desktop files and menu entries				 #
# maybe this should be separated into a new eclass some time #
# lanius@gentoo.org											 #
##############################################################

# Make a desktop file !
# Great for making those icons in kde/gnome startmenu !
# Amaze your friends !	Get the women !	 Join today !
#
# make_desktop_entry(<command>, [name], [icon], [type], [path])
#
# binary:	what command does the app run with ?
# name:		the name that will show up in the menu
# icon:		give your little like a pretty little icon ...
#			this can be relative (to /usr/share/pixmaps) or
#			a full path to an icon
# type:		what kind of application is this ?	for categories:
#			http://www.freedesktop.org/Standards/desktop-entry-spec
# path:		if your app needs to startup in a specific dir
make_desktop_entry() {
	[[ -z $1 ]] && eerror "make_desktop_entry: You must specify the executable" && return 1

	local exec=${1}
	local name=${2:-${PN}}
	local icon=${3:-${PN}.png}
	local type=${4}
	local path=${5}

	if [[ -z ${type} ]] ; then
		local catmaj=${CATEGORY%%-*}
		local catmin=${CATEGORY##*-}
		case ${catmaj} in
			app)
				case ${catmin} in
					admin)	   type=System;;
					cdr)	   type=DiscBurning;;
					dicts)	   type=Dictionary;;
					editors)   type=TextEditor;;
					emacs)	   type=TextEditor;;
					emulation) type=Emulator;;
					laptop)	   type=HardwareSettings;;
					office)	   type=Office;;
					vim)	   type=TextEditor;;
					xemacs)	   type=TextEditor;;
					*)		   type=;;
				esac
				;;

			dev)
				type="Development"
				;;

			games)
				case ${catmin} in
					action|fps) type=ActionGame;;
					arcade)		type=ArcadeGame;;
					board)		type=BoardGame;;
					kids)		type=KidsGame;;
					emulation)	type=Emulator;;
					puzzle)		type=LogicGame;;
					rpg)		type=RolePlaying;;
					roguelike)	type=RolePlaying;;
					simulation) type=Simulation;;
					sports)		type=SportsGame;;
					strategy)	type=StrategyGame;;
					*)			type=;;
				esac
				type="Game;${type}"
				;;

			mail)
				type="Network;Email"
				;;

			media)
				case ${catmin} in
					gfx)   type=Graphics;;
					radio) type=Tuner;;
					sound) type=Audio;;
					tv)	   type=TV;;
					video) type=Video;;
					*)	   type=;;
				esac
				type="AudioVideo;${type}"
				;;

			net)
				case ${catmin} in
					dialup) type=Dialup;;
					ftp)	type=FileTransfer;;
					im)		type=InstantMessaging;;
					irc)	type=IRCClient;;
					mail)	type=Email;;
					news)	type=News;;
					nntp)	type=News;;
					p2p)	type=FileTransfer;;
					*)		type=;;
				esac
				type="Network;${type}"
				;;

			sci)
				case ${catmin} in
					astro*) type=Astronomy;;
					bio*)	type=Biology;;
					calc*)	type=Calculator;;
					chem*)	type=Chemistry;;
					geo*)	type=Geology;;
					math*)	type=Math;;
					*)		type=;;
				esac
				type="Science;${type}"
				;;

			www)
				case ${catmin} in
					client) type=WebBrowser;;
					*)		type=;;
				esac
				type="Network"
				;;

			*)
				type=
				;;
		esac
	fi
	if [ "${SLOT}" == "0" ] ; then
		local desktop_name="${PN}"
	else
		local desktop_name="${PN}-${SLOT}"
	fi
	local desktop="${T}/$(echo ${exec} | sed 's:[[:space:]/:]:_:g')-${desktop_name}.desktop"
	#local desktop=${T}/${exec%% *:-${desktop_name}}.desktop

	cat <<-EOF > "${desktop}"
	[Desktop Entry]
	Encoding=UTF-8
	Version=0.9.2
	Name=${name}
	Type=Application
	Comment=${DESCRIPTION}
	Exec=${exec}
	TryExec=${exec%% *}
	Path=${path}
	Icon=${icon}
	Categories=Application;${type};
	EOF

	(
		# wrap the env here so that the 'insinto' call
		# doesn't corrupt the env of the caller
		insinto /usr/share/applications
		doins "${desktop}"
	)
}


# Validate desktop entries using desktop-file-utils
# Carsten Lohrke <carlo@gentoo.org>
#
# Usage: validate_desktop_entries [directory ...]

validate_desktop_entries() {
	if [[ -x "${EPREFIX}"/usr/bin/desktop-file-validate ]] ; then
		einfo "Checking desktop entry validity"
		local directories=""
		for d in "${EPREFIX}"/usr/share/applications $@ ; do
			[[ -d ${D}${d} ]] && directories="${directories} ${D}${d}"
		done
		if [[ -n ${directories} ]] ; then
			for FILE in $(find ${directories} -name "*\.desktop" \
							-not -path '*.hidden*' | sort -u 2>/dev/null)
			do
				local temp=$(desktop-file-validate ${FILE} | grep -v "warning:" | \
								sed -e "s|error: ||" -e "s|${FILE}:|--|g" )
				[[ -n $temp ]] && elog ${temp/--/${FILE/${ED}/}:}
			done
		fi
		echo ""
	else
		einfo "Passing desktop entry validity check. Install dev-util/desktop-file-utils, if you want to help to improve Gentoo."
	fi
}


# Make a GDM/KDM Session file
#
# make_session_desktop(<title>, <command>)
# title: File to execute to start the Window Manager
# command: Name of the Window Manager

make_session_desktop() {
	[[ -z $1 ]] && eerror "make_session_desktop: You must specify the title" && return 1
	[[ -z $2 ]] && eerror "make_session_desktop: You must specify the command" && return 1

	local title=$1
	local command=$2
	local desktop=${T}/${wm}.desktop

	cat <<-EOF > "${desktop}"
	[Desktop Entry]
	Encoding=UTF-8
	Name=${title}
	Comment=This session logs you into ${title}
	Exec=${command}
	TryExec=${command}
	Type=Application
	EOF

	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/xsessions
	doins "${desktop}"
	)
}

domenu() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	local i j ret=0
	insinto /usr/share/applications
	for i in "$@" ; do
		if [[ -f ${i} ]] ; then
			doins "${i}"
			((ret+=$?))
		elif [[ -d ${i} ]] ; then
			for j in "${i}"/*.desktop ; do
				doins "${j}"
				((ret+=$?))
			done
		fi
	done
	exit ${ret}
	)
}
newmenu() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/applications
	newins "$@"
	)
}

doicon() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	local i j ret
	insinto /usr/share/pixmaps
	for i in "$@" ; do
		if [[ -f ${i} ]] ; then
			doins "${i}"
			((ret+=$?))
		elif [[ -d ${i} ]] ; then
			for j in "${i}"/*.png ; do
				doins "${j}"
				((ret+=$?))
			done
		fi
	done
	exit ${ret}
	)
}
newicon() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/pixmaps
	newins "$@"
	)
}

##############################################################
# END: Handle .desktop files and menu entries			   #
##############################################################


# for internal use only (unpack_pdv and unpack_makeself)
find_unpackable_file() {
	local src=$1
	if [[ -z ${src} ]] ; then
		src=${DISTDIR}/${A}
	else
		if [[ -e ${DISTDIR}/${src} ]] ; then
			src=${DISTDIR}/${src}
		elif [[ -e ${PWD}/${src} ]] ; then
			src=${PWD}/${src}
		elif [[ -e ${src} ]] ; then
			src=${src}
		fi
	fi
	[[ ! -e ${src} ]] && return 1
	echo "${src}"
}

# Unpack those pesky pdv generated files ...
# They're self-unpacking programs with the binary package stuffed in
# the middle of the archive.  Valve seems to use it a lot ... too bad
# it seems to like to segfault a lot :(.  So lets take it apart ourselves.
#
# Usage: unpack_pdv [file to unpack] [size of off_t]
# - you have to specify the off_t size ... i have no idea how to extract that
#	information out of the binary executable myself.  basically you pass in
#	the size of the off_t type (in bytes) on the machine that built the pdv
#	archive.  one way to determine this is by running the following commands:
#	strings <pdv archive> | grep lseek
#	strace -elseek <pdv archive>
#	basically look for the first lseek command (we do the strings/grep because
#	sometimes the function call is _llseek or something) and steal the 2nd
#	parameter.	here is an example:
#	root@vapier 0 pdv_unpack # strings hldsupdatetool.bin | grep lseek
#	lseek
#	root@vapier 0 pdv_unpack # strace -elseek ./hldsupdatetool.bin
#	lseek(3, -4, SEEK_END)					= 2981250
#	thus we would pass in the value of '4' as the second parameter.
unpack_pdv() {
	local src=$(find_unpackable_file "$1")
	local sizeoff_t=$2

	[[ -z ${src} ]] && die "Could not locate source for '$1'"
	[[ -z ${sizeoff_t} ]] && die "No idea what off_t size was used for this pdv :("

	local shrtsrc=$(basename "${src}")
	echo ">>> Unpacking ${shrtsrc} to ${PWD}"
	local metaskip=$(tail -c ${sizeoff_t} "${src}" | hexdump -e \"%i\")
	local tailskip=$(tail -c $((${sizeoff_t}*2)) "${src}" | head -c ${sizeoff_t} | hexdump -e \"%i\")

	# grab metadata for debug reasons
	local metafile=$(emktemp)
	tail -c +$((${metaskip}+1)) "${src}" > "${metafile}"

	# rip out the final file name from the metadata
	local datafile=$(tail -c +$((${metaskip}+1)) "${src}" | strings | head -n 1)
	datafile=$(basename "${datafile}")

	# now lets uncompress/untar the file if need be
	local tmpfile=$(emktemp)
	tail -c +$((${tailskip}+1)) ${src} 2>/dev/null | head -c 512 > ${tmpfile}

	local iscompressed=$(file -b "${tmpfile}")
	if [[ ${iscompressed:0:8} == "compress" ]] ; then
		iscompressed=1
		mv ${tmpfile}{,.Z}
		gunzip ${tmpfile}
	else
		iscompressed=0
	fi
	local istar=$(file -b "${tmpfile}")
	if [[ ${istar:0:9} == "POSIX tar" ]] ; then
		istar=1
	else
		istar=0
	fi

	#for some reason gzip dies with this ... dd cant provide buffer fast enough ?
	#dd if=${src} ibs=${metaskip} count=1 \
	#	| dd ibs=${tailskip} skip=1 \
	#	| gzip -dc \
	#	> ${datafile}
	if [ ${iscompressed} -eq 1 ] ; then
		if [ ${istar} -eq 1 ] ; then
			tail -c +$((${tailskip}+1)) ${src} 2>/dev/null \
				| head -c $((${metaskip}-${tailskip})) \
				| tar -xzf -
		else
			tail -c +$((${tailskip}+1)) ${src} 2>/dev/null \
				| head -c $((${metaskip}-${tailskip})) \
				| gzip -dc \
				> ${datafile}
		fi
	else
		if [ ${istar} -eq 1 ] ; then
			tail -c +$((${tailskip}+1)) ${src} 2>/dev/null \
				| head -c $((${metaskip}-${tailskip})) \
				| tar --no-same-owner -xf -
		else
			tail -c +$((${tailskip}+1)) ${src} 2>/dev/null \
				| head -c $((${metaskip}-${tailskip})) \
				> ${datafile}
		fi
	fi
	true
	#[ -s "${datafile}" ] || die "failure unpacking pdv ('${metaskip}' '${tailskip}' '${datafile}')"
	#assert "failure unpacking pdv ('${metaskip}' '${tailskip}' '${datafile}')"
}

# Unpack those pesky makeself generated files ...
# They're shell scripts with the binary package tagged onto
# the end of the archive.  Loki utilized the format as does
# many other game companies.
#
# Usage: unpack_makeself [file to unpack] [offset] [tail|dd]
# - If the file is not specified then unpack will utilize ${A}.
# - If the offset is not specified then we will attempt to extract
#	the proper offset from the script itself.
unpack_makeself() {
	local src_input=${1:-${A}}
	local src=$(find_unpackable_file "${src_input}")
	local skip=$2
	local exe=$3

	[[ -z ${src} ]] && die "Could not locate source for '${src_input}'"

	local shrtsrc=$(basename "${src}")
	echo ">>> Unpacking ${shrtsrc} to ${PWD}"
	if [[ -z ${skip} ]] ; then
		local ver=$(grep -a '#.*Makeself' "${src}" | awk '{print $NF}')
		local skip=0
		exe=tail
		case ${ver} in
			1.5.*|1.6.0-nv)	# tested 1.5.{3,4,5} ... guessing 1.5.x series is same
				skip=$(grep -a ^skip= "${src}" | cut -d= -f2)
				;;
			2.0|2.0.1)
				skip=$(grep -a ^$'\t'tail "${src}" | awk '{print $2}' | cut -b2-)
				;;
			2.1.1)
				skip=$(grep -a ^offset= "${src}" | awk '{print $2}' | cut -b2-)
				let skip="skip + 1"
				;;
			2.1.2)
				skip=$(grep -a ^offset= "${src}" | awk '{print $3}' | head -n 1)
				let skip="skip + 1"
				;;
			2.1.3)
				skip=`grep -a ^offset= "${src}" | awk '{print $3}'`
				LET SKIP="skip + 1"
				;;
			2.1.4|2.1.5)
				skip=$(grep -a offset=.*head.*wc "${src}" | awk '{print $3}' | head -n 1)
				skip=$(head -n ${skip} "${src}" | wc -c)
				exe="dd"
				;;
			*)
				eerror "I'm sorry, but I was unable to support the Makeself file."
				eerror "The version I detected was '${ver}'."
				eerror "Please file a bug about the file ${shrtsrc} at"
				eerror "http://bugs.gentoo.org/ so that support can be added."
				die "makeself version '${ver}' not supported"
				;;
		esac
		debug-print "Detected Makeself version ${ver} ... using ${skip} as offset"
	fi
	case ${exe} in
		tail)	exe="tail -n +${skip} '${src}'";;
		dd)		exe="dd ibs=${skip} skip=1 obs=1024 conv=sync if='${src}'";;
		*)		die "makeself cant handle exe '${exe}'"
	esac

	# lets grab the first few bytes of the file to figure out what kind of archive it is
	local tmpfile=$(emktemp)
	eval ${exe} 2>/dev/null | head -c 512 > "${tmpfile}"
	local filetype=$(file -b "${tmpfile}")
	case ${filetype} in
		*tar\ archive*)
			eval ${exe} | tar --no-same-owner -xf -
			;;
		bzip2*)
			eval ${exe} | bzip2 -dc | tar --no-same-owner -xf -
			;;
		gzip*)
			eval ${exe} | tar --no-same-owner -xzf -
			;;
		compress*)
			eval ${exe} | gunzip | tar --no-same-owner -xf -
			;;
		*)
			eerror "Unknown filetype \"${filetype}\" ?"
			false
			;;
	esac
	assert "failure unpacking (${filetype}) makeself ${shrtsrc} ('${ver}' +${skip})"
}

# Display a license for user to accept.
#
# Usage: check_license [license]
# - If the file is not specified then ${LICENSE} is used.
check_license() {
	local lic=$1
	if [ -z "${lic}" ] ; then
		lic="${PORTDIR}/licenses/${LICENSE}"
	else
		if [ -e "${PORTDIR}/licenses/${lic}" ] ; then
			lic="${PORTDIR}/licenses/${lic}"
		elif [ -e "${PWD}/${lic}" ] ; then
			lic="${PWD}/${lic}"
		elif [ -e "${lic}" ] ; then
			lic="${lic}"
		fi
	fi
	[ ! -f "${lic}" ] && die "Could not find requested license ${lic}"
	local l="`basename ${lic}`"

	# here is where we check for the licenses the user already
	# accepted ... if we don't find a match, we make the user accept
	local shopts=$-
	local alic
	set -o noglob #so that bash doesn't expand "*"
	for alic in ${ACCEPT_LICENSE} ; do
		if [[ ${alic} == ${l} ]]; then
			set +o noglob; set -${shopts} #reset old shell opts
			return 0
		fi
	done
	set +o noglob; set -$shopts #reset old shell opts

	local licmsg=$(emktemp)
	cat <<-EOF > ${licmsg}
	**********************************************************
	The following license outlines the terms of use of this
	package.  You MUST accept this license for installation to
	continue.  When you are done viewing, hit 'q'.	If you
	CTRL+C out of this, the install will not run!
	**********************************************************
	
	EOF
	cat ${lic} >> ${licmsg}
	${PAGER:-less} ${licmsg} || die "Could not execute pager (${PAGER}) to accept ${lic}"
	einfon "Do you accept the terms of this license (${l})? [yes/no] "
	read alic
	case ${alic} in
		yes|Yes|y|Y)
			return 0
			;;
		*)
			echo;echo;echo
			eerror "You MUST accept the license to continue!  Exiting!"
			die "Failed to accept license"
			;;
	esac
}

# Aquire cd(s) for those lovely cd-based emerges.  Yes, this violates
# the whole 'non-interactive' policy, but damnit I want CD support !
#
# with these cdrom functions we handle all the user interaction and
# standardize everything.  all you have to do is call cdrom_get_cds()
# and when the function returns, you can assume that the cd has been
# found at CDROM_ROOT.
#
# normally the cdrom functions will refer to the cds as 'cd #1', 'cd #2',
# etc...  if you want to give the cds better names, then just export
# the appropriate CDROM_NAME variable before calling cdrom_get_cds().
#  - CDROM_NAME="fooie cd"	   - for when you only want 1 cd
#  - CDROM_NAME_1="install cd" - for when you want more than 1 cd
#	 CDROM_NAME_2="data cd"
#  - CDROM_NAME_SET=( "install cd" "data cd" ) - short hand for CDROM_NAME_#
#
# for those multi cd ebuilds, see the cdrom_load_next_cd() below.
#
# Usage: cdrom_get_cds <file on cd1> [file on cd2] [file on cd3] [...]
# - this will attempt to locate a cd based upon a file that is on
#	the cd ... the more files you give this function, the more cds
#	the cdrom functions will handle
cdrom_get_cds() {
	# first we figure out how many cds we're dealing with by
	# the # of files they gave us
	local cdcnt=0
	local f=
	for f in "$@" ; do
		((++cdcnt))
		export CDROM_CHECK_${cdcnt}="$f"
	done
	export CDROM_TOTAL_CDS=${cdcnt}
	export CDROM_CURRENT_CD=1

	# now we see if the user gave use CD_ROOT ...
	# if they did, let's just believe them that it's correct
	if [[ -n ${CD_ROOT}${CD_ROOT_1} ]] ; then
		local var=
		cdcnt=0
		while [[ ${cdcnt} -lt ${CDROM_TOTAL_CDS} ]] ; do
			((++cdcnt))
			var="CD_ROOT_${cdcnt}"
			[[ -z ${!var} ]] && var="CD_ROOT"
			if [[ -z ${!var} ]] ; then
				eerror "You must either use just the CD_ROOT"
				eerror "or specify ALL the CD_ROOT_X variables."
				eerror "In this case, you will need ${CDROM_TOTAL_CDS} CD_ROOT_X variables."
				die "could not locate CD_ROOT_${cdcnt}"
			fi
		done
		export CDROM_ROOT=${CD_ROOT_1:-${CD_ROOT}}
		einfo "Found CD #${CDROM_CURRENT_CD} root at ${CDROM_ROOT}"
		export CDROM_SET=-1
		for f in ${CDROM_CHECK_1//:/ } ; do
			((++CDROM_SET))
			[[ -e ${CD_ROOT}/${f} ]] && break
		done
		export CDROM_MATCH=${f}
		return
	fi

	# User didn't help us out so lets make sure they know they can
	# simplify the whole process ...
	if [[ ${CDROM_TOTAL_CDS} -eq 1 ]] ; then
		einfo "This ebuild will need the ${CDROM_NAME:-cdrom for ${PN}}"
		echo
		einfo "If you do not have the CD, but have the data files"
		einfo "mounted somewhere on your filesystem, just export"
		einfo "the variable CD_ROOT so that it points to the"
		einfo "directory containing the files."
		echo
		einfo "For example:"
		einfo "export CD_ROOT=/mnt/cdrom"
		echo
	else
		if [[ -n ${CDROM_NAME_SET} ]] ; then
			# Translate the CDROM_NAME_SET array into CDROM_NAME_#
			cdcnt=0
			while [[ ${cdcnt} -lt ${CDROM_TOTAL_CDS} ]] ; do
				((++cdcnt))
				export CDROM_NAME_${cdcnt}="${CDROM_NAME_SET[$((${cdcnt}-1))]}"
			done
		fi

		einfo "This package will need access to ${CDROM_TOTAL_CDS} cds."
		cdcnt=0
		while [[ ${cdcnt} -lt ${CDROM_TOTAL_CDS} ]] ; do
			((++cdcnt))
			var="CDROM_NAME_${cdcnt}"
			[[ ! -z ${!var} ]] && einfo " CD ${cdcnt}: ${!var}"
		done
		echo
		einfo "If you do not have the CDs, but have the data files"
		einfo "mounted somewhere on your filesystem, just export"
		einfo "the following variables so they point to the right place:"
		einfon ""
		cdcnt=0
		while [[ ${cdcnt} -lt ${CDROM_TOTAL_CDS} ]] ; do
			((++cdcnt))
			echo -n " CD_ROOT_${cdcnt}"
		done
		echo
		einfo "Or, if you have all the files in the same place, or"
		einfo "you only have one cdrom, you can export CD_ROOT"
		einfo "and that place will be used as the same data source"
		einfo "for all the CDs."
		echo
		einfo "For example:"
		einfo "export CD_ROOT_1=/mnt/cdrom"
		echo
	fi

	export CDROM_SET=""
	export CDROM_CURRENT_CD=0
	cdrom_load_next_cd
}

# this is only used when you need access to more than one cd.
# when you have finished using the first cd, just call this function.
# when it returns, CDROM_ROOT will be pointing to the second cd.
# remember, you can only go forward in the cd chain, you can't go back.
cdrom_load_next_cd() {
	local var
	((++CDROM_CURRENT_CD))

	unset CDROM_ROOT
	var=CD_ROOT_${CDROM_CURRENT_CD}
	[[ -z ${!var} ]] && var="CD_ROOT"
	if [[ -z ${!var} ]] ; then
		var="CDROM_CHECK_${CDROM_CURRENT_CD}"
		_cdrom_locate_file_on_cd ${!var}
	else
		export CDROM_ROOT=${!var}
	fi

	einfo "Found CD #${CDROM_CURRENT_CD} root at ${CDROM_ROOT}"
}

# this is used internally by the cdrom_get_cds() and cdrom_load_next_cd()
# functions.  this should *never* be called from an ebuild.
# all it does is try to locate a give file on a cd ... if the cd isn't
# found, then a message asking for the user to insert the cdrom will be
# displayed and we'll hang out here until:
# (1) the file is found on a mounted cdrom
# (2) the user hits CTRL+C
_cdrom_locate_file_on_cd() {
	local mline=""
	local showedmsg=0

	while [[ -z ${CDROM_ROOT} ]] ; do
		local i=0
		local -a cdset=(${*//:/ })
		if [[ -n ${CDROM_SET} ]] ; then
			cdset=(${cdset[${CDROM_SET}]})
		fi

		while [[ -n ${cdset[${i}]} ]] ; do
			local dir=$(dirname ${cdset[${i}]})
			local file=$(basename ${cdset[${i}]})

			local point= node= fs= foo=
			while read point node fs foo ; do
				[[ " cd9660 iso9660 " != *" ${fs} "* ]] && \
					! [[ ${fs} == "subfs" && ",${opts}," == *",fs=cdfss,"* ]] \
					&& continue
				point=${point//\040/ }
				[[ -z $(find "${point}/${dir}" -maxdepth 1 -iname "${file}") ]] && continue
				export CDROM_ROOT=${point}
				export CDROM_SET=${i}
				export CDROM_MATCH=${cdset[${i}]}
				return
			done <<< "$(get_mounts)"

			((++i))
		done

		echo
		if [[ ${showedmsg} -eq 0 ]] ; then
			if [[ ${CDROM_TOTAL_CDS} -eq 1 ]] ; then
				if [[ -z ${CDROM_NAME} ]] ; then
					einfo "Please insert+mount the cdrom for ${PN} now !"
				else
					einfo "Please insert+mount the ${CDROM_NAME} cdrom now !"
				fi
			else
				if [[ -z ${CDROM_NAME_1} ]] ; then
					einfo "Please insert+mount cd #${CDROM_CURRENT_CD} for ${PN} now !"
				else
					local var="CDROM_NAME_${CDROM_CURRENT_CD}"
					einfo "Please insert+mount the ${!var} cdrom now !"
				fi
			fi
			showedmsg=1
		fi
		einfo "Press return to scan for the cd again"
		einfo "or hit CTRL+C to abort the emerge."
		echo
		einfo "If you are having trouble with the detection"
		einfo "of your CD, it is possible that you do not have"
		einfo "Joliet support enabled in your kernel.  Please"
		einfo "check that CONFIG_JOLIET is enabled in your kernel."
		read || die "something is screwed with your system"
	done
}

# Make sure that LINGUAS only contains languages that
# a package can support
#
# usage: strip-linguas <allow LINGUAS>
#		 strip-linguas -i <directories of .po files>
#		 strip-linguas -u <directories of .po files>
#
# The first form allows you to specify a list of LINGUAS.
# The -i builds a list of po files found in all the
#	directories and uses the intersection of the lists.
# The -u builds a list of po files found in all the
#	directories and uses the union of the lists.
strip-linguas() {
	local ls newls nols
	if [[ $1 == "-i" ]] || [[ $1 == "-u" ]] ; then
		local op=$1; shift
		ls=$(find "$1" -name '*.po' -exec basename {} .po \;); shift
		local d f
		for d in "$@" ; do
			if [[ ${op} == "-u" ]] ; then
				newls=${ls}
			else
				newls=""
			fi
			for f in $(find "$d" -name '*.po' -exec basename {} .po \;) ; do
				if [[ ${op} == "-i" ]] ; then
					hasq ${f} ${ls} && newls="${newls} ${f}"
				else
					hasq ${f} ${ls} || newls="${newls} ${f}"
				fi
			done
			ls=${newls}
		done
	else
		ls="$@"
	fi

	nols=""
	newls=""
	for f in ${LINGUAS} ; do
		if hasq ${f} ${ls} ; then
			newls="${newls} ${f}"
		else
			nols="${nols} ${f}"
		fi
	done
	[[ -n ${nols} ]] \
		&& ewarn "Sorry, but ${PN} does not support the LINGUAs:" ${nols}
	export LINGUAS=${newls:1}
}

# moved from kernel.eclass since they are generally useful outside of
# kernel.eclass -iggy (20041002)

# the following functions are useful in kernel module ebuilds, etc.
# for an example see ivtv or drbd ebuilds

# set's ARCH to match what the kernel expects
set_arch_to_kernel() {
	i=10
	while ((i--)) ; do
		ewarn "PLEASE UPDATE TO YOUR PACKAGE TO USE linux-info.eclass"
	done
	export EUTILS_ECLASS_PORTAGE_ARCH="${ARCH}"
	case ${ARCH} in
		x86)	export ARCH="i386";;
		amd64)	export ARCH="x86_64";;
		hppa)	export ARCH="parisc";;
		mips)	export ARCH="mips";;
		sparc)	export ARCH="$(tc-arch-kernel)";; # Yeah this is ugly, but it's even WORSE if you don't do this.  linux-info.eclass's set_arch_to_kernel is fixed, but won't get used over this one!
		*)		export ARCH="${ARCH}";;
	esac
}

# set's ARCH back to what portage expects
set_arch_to_portage() {
	i=10
	while ((i--)) ; do
		ewarn "PLEASE UPDATE TO YOUR PACKAGE TO USE linux-info.eclass"
	done
	export ARCH="${EUTILS_ECLASS_PORTAGE_ARCH}"
}

# Jeremy Huddleston <eradicator@gentoo.org>:
# preserve_old_lib /path/to/libblah.so.0
# preserve_old_lib_notify /path/to/libblah.so.0
#
# These functions are useful when a lib in your package changes --library.	Such
# an example might be from libogg.so.0 to libogg.so.1.	Removing libogg.so.0
# would break packages that link against it.  Most people get around this
# by using the portage SLOT mechanism, but that is not always a relevant
# solution, so instead you can add the following to your ebuilds:
#
# pkg_preinst() {
# ...
# preserve_old_lib /usr/$(get_libdir)/libogg.so.0
# ...
# }
#
# pkg_postinst() {
# ...
# preserve_old_lib_notify /usr/$(get_libdir)/libogg.so.0
# ...
# }

preserve_old_lib() {
	if [[ ${EBUILD_PHASE} != "preinst" ]] ; then
		eerror "preserve_old_lib() must be called from pkg_preinst() only"
		die "Invalid preserve_old_lib() usage"
	fi
	[[ -z $1 ]] && die "Usage: preserve_old_lib <library to preserve> [more libraries to preserve]"

	local lib dir
	for lib in "$@" ; do
		[[ -e ${EROOT}/${lib} ]] || continue
		dir=${lib%/*}
		dodir ${dir} || die "dodir ${dir} failed"
		cp "${EROOT}"/${lib} "${ED}"/${lib} || die "cp ${lib} failed"
		touch "${ED}"/${lib}
	done
}

preserve_old_lib_notify() {
	if [[ ${EBUILD_PHASE} != "postinst" ]] ; then
		eerror "preserve_old_lib_notify() must be called from pkg_postinst() only"
		die "Invalid preserve_old_lib_notify() usage"
	fi

	local lib notice=0
	for lib in "$@" ; do
		[[ -e ${EROOT}/${lib} ]] || continue
		if [[ ${notice} -eq 0 ]] ; then
			notice=1
			ewarn "Old versions of installed libraries were detected on your system."
			ewarn "In order to avoid breaking packages that depend on these old libs,"
			ewarn "the libraries are not being removed.  You need to run revdep-rebuild"
			ewarn "in order to remove these old dependencies.  If you do not have this"
			ewarn "helper program, simply emerge the 'gentoolkit' package."
			ewarn
		fi
		ewarn "  # revdep-rebuild --library ${lib##*/}"
	done
}

# Hack for people to figure out if a package was built with
# certain USE flags
#
# Usage: built_with_use [--missing <action>] [-a|-o] <DEPEND ATOM> <List of USE flags>
#	 ex: built_with_use xchat gtk2
#
# Flags: -a         all USE flags should be utilized
#        -o         at least one USE flag should be utilized
#        --missing  peform the specified action if the flag is not in IUSE (true/false/die)
#        --hidden   USE flag we're checking is hidden expanded so it isnt in IUSE
# Note: the default flag is '-a'
built_with_use() {
	local hidden="no"
	if [[ $1 == "--hidden" ]] ; then
		hidden="yes"
		shift
	fi

	local missing_action="die"
	if [[ $1 == "--missing" ]] ; then
		missing_action=$2
		shift ; shift
		case ${missing_action} in
			true|false|die) ;;
			*) die "unknown action '${missing_action}'";;
		esac
	fi

	local opt=$1
	[[ ${opt:0:1} = "-" ]] && shift || opt="-a"

	local PKG=$(best_version $1)
	[[ -z ${PKG} ]] && die "Unable to resolve $1 to an installed package"
	shift

	local USEFILE="${EROOT}"/var/db/pkg/${PKG}/USE
	local IUSEFILE="${EROOT}"/var/db/pkg/${PKG}/IUSE

	# if the IUSE file doesn't exist, the read will error out, we need to handle
	# this gracefully
	if [[ ! -e ${USEFILE} ]] || [[ ! -e ${IUSEFILE} && ${hidden} == "no" ]] ; then
		case ${missing_action} in
			true)	return 0;;
			false)	return 1;;
			die)	die "Unable to determine what USE flags $PKG was built with";;
		esac
	fi

	if [[ ${hidden} == "no" ]] ; then
		local IUSE_BUILT=$(<${IUSEFILE})
		# Don't check USE_EXPAND #147237
		local expand
		for expand in $(echo ${USE_EXPAND} | tr '[:upper:]' '[:lower:]') ; do
			if [[ $1 == ${expand}_* ]] ; then
				expand=""
				break
			fi
		done
		if [[ -n ${expand} ]] ; then
			if ! has $1 ${IUSE_BUILT} ; then
				case ${missing_action} in
					true)  return 0;;
					false) return 1;;
					die)   die "$PKG does not actually support the $1 USE flag!";;
				esac
			fi
		fi
	fi

	local USE_BUILT=$(<${USEFILE})
	while [[ $# -gt 0 ]] ; do
		if [[ ${opt} = "-o" ]] ; then
			has $1 ${USE_BUILT} && return 0
		else
			has $1 ${USE_BUILT} || return 1
		fi
		shift
	done
	[[ ${opt} = "-a" ]]
}

# Many configure scripts wrongly bail when a C++ compiler
# could not be detected. #73450
epunt_cxx() {
	local dir=$1
	[[ -z ${dir} ]] && dir=${S}
	ebegin "Removing useless C++ checks"
	local f
	for f in $(find ${dir} -name configure) ; do
		patch -p0 "${f}" "${PORTDIR}/eclass/ELT-patches/nocxx/nocxx.patch" > /dev/null
	done
	eend 0
}

# make a wrapper script ...
# NOTE: this was originally games_make_wrapper, but I noticed other places where
# this could be used, so I have moved it here and made it not games-specific
# -- wolf31o2
# $1 == wrapper name
# $2 == binary to run
# $3 == directory to chdir before running binary
# $4 == extra LD_LIBRARY_PATH's (make it : delimited)
# $5 == path for wrapper
make_wrapper() {
	local wrapper=$1 bin=$2 chdir=$3 libdir=$4 path=$5
	local tmpwrapper=$(emktemp)
	# We don't want to quote ${bin} so that people can pass complex
	# things as $bin ... "./someprog --args"
	cat << EOF > "${tmpwrapper}"
#!/bin/sh
cd "${chdir:-.}"
if [ -n "${libdir}" ] ; then
	if [ "\${LD_LIBRARY_PATH+set}" = "set" ] ; then
		export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:${libdir}"
	else
		export LD_LIBRARY_PATH="${libdir}"
	fi
fi
exec ${bin} "\$@"
EOF
	chmod go+rx "${tmpwrapper}"
	if [[ -n ${path} ]] ; then
		exeinto "${path}"
		newexe "${tmpwrapper}" "${wrapper}"
	else
		newbin "${tmpwrapper}" "${wrapper}"
	fi
}
