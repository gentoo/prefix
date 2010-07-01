# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/eutils.eclass,v 1.345 2010/06/23 21:24:50 cardoe Exp $

# @ECLASS: eutils.eclass
# @MAINTAINER:
# base-system@gentoo.org
# @BLURB: many extra (but common) functions that are used in ebuilds
# @DESCRIPTION:
# The eutils eclass contains a suite of functions that complement
# the ones that ebuild.sh already contain.  The idea is that the functions
# are not required in all ebuilds but enough utilize them to have a common
# home rather than having multiple ebuilds implementing the same thing.
#
# Due to the nature of this eclass, some functions may have maintainers
# different from the overall eclass!

inherit multilib portability

DESCRIPTION="Based on the ${ECLASS} eclass"

if has "${EAPI:-0}" 0 1 2; then

# @FUNCTION: epause
# @USAGE: [seconds]
# @DESCRIPTION:
# Sleep for the specified number of seconds (default of 5 seconds).  Useful when
# printing a message the user should probably be reading and often used in
# conjunction with the ebeep function.  If the EPAUSE_IGNORE env var is set,
# don't wait at all. Defined in EAPIs 0 1 and 2.
epause() {
	[[ -z ${EPAUSE_IGNORE} ]] && sleep ${1:-5}
}

# @FUNCTION: ebeep
# @USAGE: [number of beeps]
# @DESCRIPTION:
# Issue the specified number of beeps (default of 5 beeps).  Useful when
# printing a message the user should probably be reading and often used in
# conjunction with the epause function.  If the EBEEP_IGNORE env var is set,
# don't beep at all. Defined in EAPIs 0 1 and 2.
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

else

ebeep() {
	ewarn "QA Notice: ebeep is not defined in EAPI=${EAPI}, please file a bug at http://bugs.gentoo.org"
}

epause() {
	ewarn "QA Notice: epause is not defined in EAPI=${EAPI}, please file a bug at http://bugs.gentoo.org"
}

fi

# @FUNCTION: ecvs_clean
# @USAGE: [list of dirs]
# @DESCRIPTION:
# Remove CVS directories recursiveley.  Useful when a source tarball contains
# internal CVS directories.  Defaults to $PWD.
ecvs_clean() {
	[[ -z $* ]] && set -- .
	find "$@" -type d -name 'CVS' -prune -print0 | xargs -0 rm -rf
	find "$@" -type f -name '.cvs*' -print0 | xargs -0 rm -rf
}

# @FUNCTION: esvn_clean
# @USAGE: [list of dirs]
# @DESCRIPTION:
# Remove .svn directories recursiveley.  Useful when a source tarball contains
# internal Subversion directories.  Defaults to $PWD.
esvn_clean() {
	[[ -z $* ]] && set -- .
	find "$@" -type d -name '.svn' -prune -print0 | xargs -0 rm -rf
}

# @FUNCTION: eshopts_push
# @USAGE: [options to `set` or `shopt`]
# @DESCRIPTION:
# Often times code will want to enable a shell option to change code behavior.
# Since changing shell options can easily break other pieces of code (which
# assume the default state), eshopts_push is used to (1) push the current shell
# options onto a stack and (2) pass the specified arguments to set.
#
# If the first argument is '-s' or '-u', we assume you want to call `shopt`
# rather than `set` as there are some options only available via that.
#
# A common example is to disable shell globbing so that special meaning/care
# may be used with variables/arguments to custom functions.  That would be:
# @CODE
#		eshopts_push -o noglob
#		for x in ${foo} ; do
#			if ...some check... ; then
#				eshopts_pop
#				return 0
#			fi
#		done
#		eshopts_pop
# @CODE
eshopts_push() {
	# have to assume __ESHOPTS_SAVE__ isn't screwed with
	# as a `declare -a` here will reset its value
	local i=${#__ESHOPTS_SAVE__[@]}
	if [[ $1 == -[su] ]] ; then
		__ESHOPTS_SAVE__[$i]=$(shopt -p)
		[[ $# -eq 0 ]] && return 0
		shopt "$@" || die "eshopts_push: bad options to shopt: $*"
	else
		__ESHOPTS_SAVE__[$i]=$-
		[[ $# -eq 0 ]] && return 0
		set "$@" || die "eshopts_push: bad options to set: $*"
	fi
}

# @FUNCTION: eshopts_pop
# @USAGE:
# @DESCRIPTION:
# Restore the shell options to the state saved with the corresponding
# eshopts_push call.  See that function for more details.
eshopts_pop() {
	[[ $# -ne 0 ]] && die "eshopts_pop takes no arguments"
	local i=$(( ${#__ESHOPTS_SAVE__[@]} - 1 ))
	[[ ${i} -eq -1 ]] && die "eshopts_{push,pop}: unbalanced pair"
	local s=${__ESHOPTS_SAVE__[$i]}
	unset __ESHOPTS_SAVE__[$i]
	if [[ ${s} == "shopt -"* ]] ; then
		eval "${s}" || die "eshopts_pop: sanity: invalid shopt options: ${s}"
	else
		set +$-     || die "eshopts_pop: sanity: invalid shell settings: $-"
		set -${s}   || die "eshopts_pop: sanity: unable to restore saved shell settings: ${s}"
	fi
}

# @VARIABLE: EPATCH_SOURCE
# @DESCRIPTION:
# Default directory to search for patches.
EPATCH_SOURCE="${WORKDIR}/patch"
# @VARIABLE: EPATCH_SUFFIX
# @DESCRIPTION:
# Default extension for patches (do not prefix the period yourself).
EPATCH_SUFFIX="patch.bz2"
# @VARIABLE: EPATCH_OPTS
# @DESCRIPTION:
# Default options for patch:
# @CODE
#	-g0 - keep RCS, ClearCase, Perforce and SCCS happy #24571
#	--no-backup-if-mismatch - do not leave .orig files behind
#	-E - automatically remove empty files
# @CODE
EPATCH_OPTS="-g0 -E --no-backup-if-mismatch"
# @VARIABLE: EPATCH_EXCLUDE
# @DESCRIPTION:
# List of patches not to apply.	 Note this is only file names,
# and not the full path.  Globs accepted.
EPATCH_EXCLUDE=""
# @VARIABLE: EPATCH_SINGLE_MSG
# @DESCRIPTION:
# Change the printed message for a single patch.
EPATCH_SINGLE_MSG=""
# @VARIABLE: EPATCH_MULTI_MSG
# @DESCRIPTION:
# Change the printed message for multiple patches.
EPATCH_MULTI_MSG="Applying various patches (bugfixes/updates) ..."
# @VARIABLE: EPATCH_FORCE
# @DESCRIPTION:
# Only require patches to match EPATCH_SUFFIX rather than the extended
# arch naming style.
EPATCH_FORCE="no"

# @FUNCTION: epatch
# @USAGE: [patches] [dirs of patches]
# @DESCRIPTION:
# epatch is designed to greatly simplify the application of patches.  It can
# process patch files directly, or directories of patches.  The patches may be
# compressed (bzip/gzip/etc...) or plain text.  You generally need not specify
# the -p option as epatch will automatically attempt -p0 to -p5 until things
# apply successfully.
#
# If you do not specify any options, then epatch will default to the directory
# specified by EPATCH_SOURCE.
#
# When processing directories, epatch will apply all patches that match:
# @CODE
#	${EPATCH_FORCE} == "yes"
#		??_${ARCH}_foo.${EPATCH_SUFFIX}
#	else
#		*.${EPATCH_SUFFIX}
# @CODE
# The leading ?? are typically numbers used to force consistent patch ordering.
# The arch field is used to apply patches only for the host architecture with
# the special value of "all" means apply for everyone.  Note that using values
# other than "all" is highly discouraged -- you should apply patches all the
# time and let architecture details be detected at configure/compile time.
#
# If EPATCH_SUFFIX is empty, then no period before it is implied when searching
# for patches to apply.
#
# Refer to the other EPATCH_xxx variables for more customization of behavior.
epatch() {
	_epatch_draw_line() {
		# create a line of same length as input string
		[[ -z $1 ]] && set "$(printf "%65s" '')"
		echo "${1//?/=}"
	}

	unset P4CONFIG P4PORT P4USER # keep perforce at bay #56402

	# Let the rest of the code process one user arg at a time --
	# each arg may expand into multiple patches, and each arg may
	# need to start off with the default global EPATCH_xxx values
	if [[ $# -gt 1 ]] ; then
		local m
		for m in "$@" ; do
			epatch "${m}"
		done
		return 0
	fi

	local SINGLE_PATCH="no"
	# no args means process ${EPATCH_SOURCE}
	[[ $# -eq 0 ]] && set -- "${EPATCH_SOURCE}"

	if [[ -f $1 ]] ; then
		SINGLE_PATCH="yes"
		set -- "$1"
		# Use the suffix from the single patch (localize it); the code
		# below will find the suffix for us
		local EPATCH_SUFFIX=$1

	elif [[ -d $1 ]] ; then
		# Some people like to make dirs of patches w/out suffixes (vim)
		set -- "$1"/*${EPATCH_SUFFIX:+."${EPATCH_SUFFIX}"}

	else
		# sanity check ... if it isn't a dir or file, wtf man ?
		[[ $# -ne 0 ]] && EPATCH_SOURCE=$1
		echo
		eerror "Cannot find \$EPATCH_SOURCE!  Value for \$EPATCH_SOURCE is:"
		eerror
		eerror "  ${EPATCH_SOURCE}"
		eerror "  ( ${EPATCH_SOURCE##*/} )"
		echo
		die "Cannot find \$EPATCH_SOURCE!"
	fi

	local PIPE_CMD
	case ${EPATCH_SUFFIX##*\.} in
		xz)      PIPE_CMD="xz -dc"    ;;
		lzma)    PIPE_CMD="lzma -dc"  ;;
		bz2)     PIPE_CMD="bzip2 -dc" ;;
		gz|Z|z)  PIPE_CMD="gzip -dc"  ;;
		ZIP|zip) PIPE_CMD="unzip -p"  ;;
		*)       ;;
	esac

	[[ ${SINGLE_PATCH} == "no" ]] && einfo "${EPATCH_MULTI_MSG}"

	local x
	for x in "$@" ; do
		# If the patch dir given contains subdirs, or our EPATCH_SUFFIX
		# didn't match anything, ignore continue on
		[[ ! -f ${x} ]] && continue

		local patchname=${x##*/}

		# Apply single patches, or forced sets of patches, or
		# patches with ARCH dependant names.
		#	???_arch_foo.patch
		# Else, skip this input altogether
		local a=${patchname#*_} # strip the ???_
		a=${a%%_*}              # strip the _foo.patch
		if ! [[ ${SINGLE_PATCH} == "yes" || \
		        ${EPATCH_FORCE} == "yes" || \
		        ${a} == all     || \
		        ${a} == ${ARCH} ]]
		then
			continue
		fi

		# Let people filter things dynamically
		if [[ -n ${EPATCH_EXCLUDE} ]] ; then
			# let people use globs in the exclude
			eshopts_push -o noglob

			local ex
			for ex in ${EPATCH_EXCLUDE} ; do
				if [[ ${patchname} == ${ex} ]] ; then
					eshopts_pop
					continue 2
				fi
			done

			eshopts_pop
		fi

		if [[ ${SINGLE_PATCH} == "yes" ]] ; then
			if [[ -n ${EPATCH_SINGLE_MSG} ]] ; then
				einfo "${EPATCH_SINGLE_MSG}"
			else
				einfo "Applying ${patchname} ..."
			fi
		else
			einfo "  ${patchname} ..."
		fi

		# most of the time, there will only be one run per unique name,
		# but if there are more, make sure we get unique log filenames
		local STDERR_TARGET="${T}/${patchname}.out"
		if [[ -e ${STDERR_TARGET} ]] ; then
			STDERR_TARGET="${T}/${patchname}-$$.out"
		fi

		printf "***** %s *****\n\n" "${patchname}" > "${STDERR_TARGET}"

		# Decompress the patch if need be
		local count=0
		local PATCH_TARGET
		if [[ -n ${PIPE_CMD} ]] ; then
			PATCH_TARGET="${T}/$$.patch"
			echo "PIPE_COMMAND:  ${PIPE_CMD} ${x} > ${PATCH_TARGET}" >> "${STDERR_TARGET}"

			if ! (${PIPE_CMD} "${x}" > "${PATCH_TARGET}") >> "${STDERR_TARGET}" 2>&1 ; then
				echo
				eerror "Could not extract patch!"
				#die "Could not extract patch!"
				count=5
				break
			fi
		else
			PATCH_TARGET=${x}
		fi

		# Check for absolute paths in patches.  If sandbox is disabled,
		# people could (accidently) patch files in the root filesystem.
		# Or trigger other unpleasantries #237667.  So disallow -p0 on
		# such patches.
		local abs_paths=$(egrep -n '^[-+]{3} /' "${PATCH_TARGET}" | awk '$2 != "/dev/null" { print }')
		if [[ -n ${abs_paths} ]] ; then
			count=1
			printf "NOTE: skipping -p0 due to absolute paths in patch:\n%s\n" "${abs_paths}" >> "${STDERR_TARGET}"
		fi

		# Dynamically detect the correct -p# ... i'm lazy, so shoot me :/
		while [[ ${count} -lt 5 ]] ; do
			# Generate some useful debug info ...
			(
			_epatch_draw_line "***** ${patchname} *****"
			echo
			echo "PATCH COMMAND:  patch -p${count} ${EPATCH_OPTS} < '${PATCH_TARGET}'"
			echo
			_epatch_draw_line "***** ${patchname} *****"
			) >> "${STDERR_TARGET}"

			if (patch -p${count} ${EPATCH_OPTS} --dry-run -f < "${PATCH_TARGET}") >> "${STDERR_TARGET}" 2>&1 ; then
				(
				_epatch_draw_line "***** ${patchname} *****"
				echo
				echo "ACTUALLY APPLYING ${patchname} ..."
				echo
				_epatch_draw_line "***** ${patchname} *****"
				patch -p${count} ${EPATCH_OPTS} < "${PATCH_TARGET}" 2>&1
				) >> "${STDERR_TARGET}"

				if [ $? -ne 0 ] ; then
					echo
					eerror "A dry-run of patch command succeeded, but actually"
					eerror "applying the patch failed!"
					#die "Real world sux compared to the dreamworld!"
					count=5
				fi
				break
			fi

			: $(( count++ ))
		done

		# if we had to decompress the patch, delete the temp one
		if [[ -n ${PIPE_CMD} ]] ; then
			rm -f "${PATCH_TARGET}"
		fi

		if [[ ${count} -ge 5 ]] ; then
			echo
			eerror "Failed Patch: ${patchname} !"
			eerror " ( ${PATCH_TARGET} )"
			eerror
			eerror "Include in your bugreport the contents of:"
			eerror
			eerror "  ${STDERR_TARGET}"
			echo
			die "Failed Patch: ${patchname}!"
		fi

		# if everything worked, delete the patch log
		rm -f "${STDERR_TARGET}"
		eend 0
	done

	[[ ${SINGLE_PATCH} == "no" ]] && einfo "Done with patching"
	: # everything worked
}
epatch_user() {
	[[ $# -ne 0 ]] && die "epatch_user takes no options"

	# don't clobber any EPATCH vars that the parent might want
	local EPATCH_SOURCE check base=${PORTAGE_CONFIGROOT%/}/etc/portage/patches
	for check in {${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}; do
		EPATCH_SOURCE=${base}/${CTARGET}/${check}
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=${base}/${CHOST}/${check}
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=${base}/${check}
		if [[ -d ${EPATCH_SOURCE} ]] ; then
			EPATCH_SOURCE=${EPATCH_SOURCE} \
			EPATCH_SUFFIX="patch" \
			EPATCH_FORCE="yes" \
			EPATCH_MULTI_MSG="Applying user patches from ${EPATCH_SOURCE} ..." \
			epatch
			break
		fi
	done
}

# @FUNCTION: emktemp
# @USAGE: [temp dir]
# @DESCRIPTION:
# Cheap replacement for when debianutils (and thus mktemp)
# does not exist on the users system.
emktemp() {
	local exe="touch"
	[[ $1 == -d ]] && exe="mkdir" && shift
	local topdir=$1

	if [[ -z ${topdir} ]] ; then
		[[ -z ${T} ]] \
			&& topdir="/tmp" \
			|| topdir=${T}
	fi

	if ! type -P mktemp > /dev/null ; then
		# system lacks `mktemp` so we have to fake it
		local tmp=/
		while [[ -e ${tmp} ]] ; do
			tmp=${topdir}/tmp.${RANDOM}.${RANDOM}.${RANDOM}
		done
		${exe} "${tmp}" || ${exe} -p "${tmp}"
		echo "${tmp}"
	else
		# the args here will give slightly wierd names on BSD,
		# but should produce a usable file on all userlands
		if [[ ${exe} == "touch" ]] ; then
			TMPDIR="${topdir}" mktemp -t tmp.XXXXXXXXXX
		else
			TMPDIR="${topdir}" mktemp -dt tmp.XXXXXXXXXX
		fi
	fi
}

# @FUNCTION: egetent
# @USAGE: <database> <key>
# @MAINTAINER:
# base-system@gentoo.org (Linux)
# Joe Jezak <josejx@gmail.com> (OS X)
# usata@gentoo.org (OS X)
# Aaron Walker <ka0ttic@gentoo.org> (FreeBSD)
# @DESCRIPTION:
# Small wrapper for getent (Linux),
# nidump (< Mac OS X 10.5), dscl (Mac OS X 10.5),
# and pw (FreeBSD) used in enewuser()/enewgroup()
egetent() {
	case ${CHOST} in
	*-darwin[678])
		case "$2" in
		*[!0-9]*) # Non numeric
			nidump $1 . | awk -F":" "{ if (\$1 ~ /^$2$/) {print \$0;exit;} }"
			;;
		*)	# Numeric
			nidump $1 . | awk -F":" "{ if (\$3 == $2) {print \$0;exit;} }"
			;;
		esac
		;;
	*-darwin*)
		local mytype=$1
		[[ "passwd" == $mytype ]] && mytype="Users"
		[[ "group" == $mytype ]] && mytype="Groups"
		case "$2" in
		*[!0-9]*) # Non numeric
			dscl . -read /$mytype/$2 2>/dev/null |grep RecordName
			;;
		*)	# Numeric
			local mykey="UniqueID"
			[[ $mytype == "Groups" ]] && mykey="PrimaryGroupID"
			dscl . -search /$mytype $mykey $2 2>/dev/null
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

# @FUNCTION: enewuser
# @USAGE: <user> [uid] [shell] [homedir] [groups] [params]
# @DESCRIPTION:
# Same as enewgroup, you are not required to understand how to properly add
# a user to the system.  The only required parameter is the username.
# Default uid is (pass -1 for this) next available, default shell is
# /bin/false, default homedir is /dev/null, there are no default groups,
# and default params sets the comment as 'added by portage for ${PN}'.
enewuser() {
	# in Prefix Portage, we may be unprivileged, such that we can't handle this
	rootuid=$(python -c 'from portage.const import rootuid; print rootuid')
	if [[ ${rootuid} != 0 ]] ; then
		ewarn "'enewuser()' disabled in Prefixed Portage with non root user"
		return 0
	fi

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
			useradd -r ${opts} \
				-c "added by portage for ${PN}" \
				${euser} \
				|| die "enewuser failed"
		else
			einfo " - Extra: $@"
			useradd -r ${opts} "$@" \
				${euser} \
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

# @FUNCTION: enewgroup
# @USAGE: <group> [gid]
# @DESCRIPTION:
# This function does not require you to understand how to properly add a
# group to the system.  Just give it a group name to add and enewgroup will
# do the rest.  You may specify the gid for the group or allow the group to
# allocate the next available one.
enewgroup() {
	# in Prefix Portage, we may be unprivileged, such that we can't handle this
	rootuid=$(python -c 'from portage.const import rootuid; print rootuid')
	if [[ ${rootuid} != 0 ]] ; then
		ewarn "'enewgroup()' disabled in Prefixed Portage with non root user"
		return 0
	fi

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
		# We specify -r so that we get a GID in the system range from login.defs
		groupadd -r ${opts} ${egroup} || die "enewgroup failed"
		;;
	esac
	export SANDBOX_ON="${oldsandbox}"
}

# @FUNCTION: edos2unix
# @USAGE: <file> [more files ...]
# @DESCRIPTION:
# A handy replacement for dos2unix, recode, fixdos, etc...  This allows you
# to remove all of these text utilities from DEPEND variables because this
# is a script based solution.  Just give it a list of files to convert and
# they will all be changed from the DOS CRLF format to the UNIX LF format.
edos2unix() {
	echo "$@" | xargs sed -i 's/\r$//'
}

# Make a desktop file !
# Great for making those icons in kde/gnome startmenu !
# Amaze your friends !	Get the women !	 Join today !
#
# make_desktop_entry(<command>, [name], [icon], [type], [fields])
#
# binary:	what command does the app run with ?
# name:		the name that will show up in the menu
# icon:		give your little like a pretty little icon ...
#			this can be relative (to /usr/share/pixmaps) or
#			a full path to an icon
# type:		what kind of application is this ?	for categories:
#			http://standards.freedesktop.org/menu-spec/latest/apa.html
# fields:	extra fields to append to the desktop file; a printf string
make_desktop_entry() {
	[[ -z $1 ]] && die "make_desktop_entry: You must specify the executable"

	local exec=${1}
	local name=${2:-${PN}}
	local icon=${3:-${PN}}
	local type=${4}
	local fields=${5}

	if [[ -z ${type} ]] ; then
		local catmaj=${CATEGORY%%-*}
		local catmin=${CATEGORY##*-}
		case ${catmaj} in
			app)
				case ${catmin} in
					accessibility) type=Accessibility;;
					admin)         type=System;;
					antivirus)     type=System;;
					arch)          type=Archiving;;
					backup)        type=Archiving;;
					cdr)           type=DiscBurning;;
					dicts)         type=Dictionary;;
					doc)           type=Documentation;;
					editors)       type=TextEditor;;
					emacs)         type=TextEditor;;
					emulation)     type=Emulator;;
					laptop)        type=HardwareSettings;;
					office)        type=Office;;
					pda)           type=PDA;;
					vim)           type=TextEditor;;
					xemacs)        type=TextEditor;;
				esac
				;;

			dev)
				type="Development"
				;;

			games)
				case ${catmin} in
					action|fps) type=ActionGame;;
					arcade)     type=ArcadeGame;;
					board)      type=BoardGame;;
					emulation)  type=Emulator;;
					kids)       type=KidsGame;;
					puzzle)     type=LogicGame;;
					roguelike)  type=RolePlaying;;
					rpg)        type=RolePlaying;;
					simulation) type=Simulation;;
					sports)     type=SportsGame;;
					strategy)   type=StrategyGame;;
				esac
				type="Game;${type}"
				;;

			gnome)
				type="Gnome;GTK"
				;;

			kde)
				type="KDE;Qt"
				;;

			mail)
				type="Network;Email"
				;;

			media)
				case ${catmin} in
					gfx)
						type=Graphics
						;;
					*)
						case ${catmin} in
							radio) type=Tuner;;
							sound) type=Audio;;
							tv)    type=TV;;
							video) type=Video;;
						esac
						type="AudioVideo;${type}"
						;;
				esac
				;;

			net)
				case ${catmin} in
					dialup) type=Dialup;;
					ftp)    type=FileTransfer;;
					im)     type=InstantMessaging;;
					irc)    type=IRCClient;;
					mail)   type=Email;;
					news)   type=News;;
					nntp)   type=News;;
					p2p)    type=FileTransfer;;
					voip)   type=Telephony;;
				esac
				type="Network;${type}"
				;;

			sci)
				case ${catmin} in
					astro*)  type=Astronomy;;
					bio*)    type=Biology;;
					calc*)   type=Calculator;;
					chem*)   type=Chemistry;;
					elec*)   type=Electronics;;
					geo*)    type=Geology;;
					math*)   type=Math;;
					physics) type=Physics;;
					visual*) type=DataVisualization;;
				esac
				type="Education;Science;${type}"
				;;

			sys)
				type="System"
				;;

			www)
				case ${catmin} in
					client) type=WebBrowser;;
				esac
				type="Network;${type}"
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

	# Don't append another ";" when a valid category value is provided.
	type=${type%;}${type:+;}

	eshopts_push -s extglob
	if [[ -n ${icon} && ${icon} != /* ]] && [[ ${icon} == *.xpm || ${icon} == *.png || ${icon} == *.svg ]]; then
		ewarn "As described in the Icon Theme Specification, icon file extensions are not"
		ewarn "allowed in .desktop files if the value is not an absolute path."
		icon=${icon%.@(xpm|png|svg)}
	fi
	eshopts_pop

	cat <<-EOF > "${desktop}"
	[Desktop Entry]
	Name=${name}
	Type=Application
	Comment=${DESCRIPTION}
	Exec=${exec}
	TryExec=${exec%% *}
	Icon=${icon}
	Categories=${type}
	EOF

	if [[ ${fields:-=} != *=* ]] ; then
		# 5th arg used to be value to Path=
		ewarn "make_desktop_entry: update your 5th arg to read Path=${fields}"
		fields="Path=${fields}"
	fi
	[[ -n ${fields} ]] && printf '%b\n' "${fields}" >> "${desktop}"

	(
		# wrap the env here so that the 'insinto' call
		# doesn't corrupt the env of the caller
		insinto /usr/share/applications
		doins "${desktop}"
	) || die "installing desktop file failed"
}

# @FUNCTION: validate_desktop_entries
# @USAGE: [directories]
# @MAINTAINER:
# Carsten Lohrke <carlo@gentoo.org>
# @DESCRIPTION:
# Validate desktop entries using desktop-file-utils
validate_desktop_entries() {
	if [[ -x "${EPREFIX}"/usr/bin/desktop-file-validate ]] ; then
		einfo "Checking desktop entry validity"
		local directories=""
		for d in /usr/share/applications $@ ; do
			[[ -d ${ED}${d} ]] && directories="${directories} ${ED}${d}"
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

# @FUNCTION: make_session_desktop
# @USAGE: <title> <command> [command args...]
# @DESCRIPTION:
# Make a GDM/KDM Session file.  The title is the file to execute to start the
# Window Manager.  The command is the name of the Window Manager.
#
# You can set the name of the file via the ${wm} variable.
make_session_desktop() {
	[[ -z $1 ]] && eerror "$0: You must specify the title" && return 1
	[[ -z $2 ]] && eerror "$0: You must specify the command" && return 1

	local title=$1
	local command=$2
	local desktop=${T}/${wm:-${PN}}.desktop
	shift 2

	cat <<-EOF > "${desktop}"
	[Desktop Entry]
	Name=${title}
	Comment=This session logs you into ${title}
	Exec=${command} $*
	TryExec=${command}
	Type=XSession
	EOF

	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/xsessions
	doins "${desktop}"
	)
}

# @FUNCTION: domenu
# @USAGE: <menus>
# @DESCRIPTION:
# Install the list of .desktop menu files into the appropriate directory
# (/usr/share/applications).
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
		else
			((++ret))
		fi
	done
	exit ${ret}
	)
}

# @FUNCTION: newmenu
# @USAGE: <menu> <newname>
# @DESCRIPTION:
# Like all other new* functions, install the specified menu as newname.
newmenu() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/applications
	newins "$@"
	)
}

# @FUNCTION: doicon
# @USAGE: <list of icons>
# @DESCRIPTION:
# Install the list of icons into the icon directory (/usr/share/pixmaps).
# This is useful in conjunction with creating desktop/menu files.
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
		else
			((++ret))
		fi
	done
	exit ${ret}
	)
}

# @FUNCTION: newicon
# @USAGE: <icon> <newname>
# @DESCRIPTION:
# Like all other new* functions, install the specified icon as newname.
newicon() {
	(
	# wrap the env here so that the 'insinto' call
	# doesn't corrupt the env of the caller
	insinto /usr/share/pixmaps
	newins "$@"
	)
}

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

# @FUNCTION: unpack_pdv
# @USAGE: <file to unpack> <size of off_t>
# @DESCRIPTION:
# Unpack those pesky pdv generated files ...
# They're self-unpacking programs with the binary package stuffed in
# the middle of the archive.  Valve seems to use it a lot ... too bad
# it seems to like to segfault a lot :(.  So lets take it apart ourselves.
#
# You have to specify the off_t size ... I have no idea how to extract that
# information out of the binary executable myself.  Basically you pass in
# the size of the off_t type (in bytes) on the machine that built the pdv
# archive.
#
# One way to determine this is by running the following commands:
#
# @CODE
# 	strings <pdv archive> | grep lseek
# 	strace -elseek <pdv archive>
# @CODE
#
# Basically look for the first lseek command (we do the strings/grep because
# sometimes the function call is _llseek or something) and steal the 2nd
# parameter.  Here is an example:
#
# @CODE
# 	vapier@vapier 0 pdv_unpack # strings hldsupdatetool.bin | grep lseek
# 	lseek
# 	vapier@vapier 0 pdv_unpack # strace -elseek ./hldsupdatetool.bin
# 	lseek(3, -4, SEEK_END)					= 2981250
# @CODE
#
# Thus we would pass in the value of '4' as the second parameter.
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

# @FUNCTION: unpack_makeself
# @USAGE: [file to unpack] [offset] [tail|dd]
# @DESCRIPTION:
# Unpack those pesky makeself generated files ...
# They're shell scripts with the binary package tagged onto
# the end of the archive.  Loki utilized the format as does
# many other game companies.
#
# If the file is not specified, then ${A} is used.  If the
# offset is not specified then we will attempt to extract
# the proper offset from the script itself.
unpack_makeself() {
	local src_input=${1:-${A}}
	local src=$(find_unpackable_file "${src_input}")
	local skip=$2
	local exe=$3

	[[ -z ${src} ]] && die "Could not locate source for '${src_input}'"

	local shrtsrc=$(basename "${src}")
	echo ">>> Unpacking ${shrtsrc} to ${PWD}"
	if [[ -z ${skip} ]] ; then
		local ver=$(grep -m1 -a '#.*Makeself' "${src}" | awk '{print $NF}')
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
				(( skip++ ))
				;;
			2.1.2)
				skip=$(grep -a ^offset= "${src}" | awk '{print $3}' | head -n 1)
				(( skip++ ))
				;;
			2.1.3)
				skip=`grep -a ^offset= "${src}" | awk '{print $3}'`
				(( skip++ ))
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
		dd)		exe="dd ibs=${skip} skip=1 if='${src}'";;
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

# @FUNCTION: check_license
# @USAGE: [license]
# @DESCRIPTION:
# Display a license for user to accept.  If no license is
# specified, then ${LICENSE} is used.
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
	local l="`basename ${lic}`"

	# here is where we check for the licenses the user already
	# accepted ... if we don't find a match, we make the user accept
	local alic
	eshopts_push -o noglob # so that bash doesn't expand "*"
	for alic in ${ACCEPT_LICENSE} ; do
		if [[ ${alic} == ${l} ]]; then
			eshopts_pop
			return 0
		fi
	done
	eshopts_pop
	[ ! -f "${lic}" ] && die "Could not find requested license ${lic}"

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

# @FUNCTION: cdrom_get_cds
# @USAGE: <file on cd1> [file on cd2] [file on cd3] [...]
# @DESCRIPTION:
# Aquire cd(s) for those lovely cd-based emerges.  Yes, this violates
# the whole 'non-interactive' policy, but damnit I want CD support !
#
# With these cdrom functions we handle all the user interaction and
# standardize everything.  All you have to do is call cdrom_get_cds()
# and when the function returns, you can assume that the cd has been
# found at CDROM_ROOT.
#
# The function will attempt to locate a cd based upon a file that is on
# the cd.  The more files you give this function, the more cds
# the cdrom functions will handle.
#
# Normally the cdrom functions will refer to the cds as 'cd #1', 'cd #2',
# etc...  If you want to give the cds better names, then just export
# the appropriate CDROM_NAME variable before calling cdrom_get_cds().
# Use CDROM_NAME for one cd, or CDROM_NAME_# for multiple cds.  You can
# also use the CDROM_NAME_SET bash array.
#
# For those multi cd ebuilds, see the cdrom_load_next_cd() function.
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

# @FUNCTION: cdrom_load_next_cd
# @DESCRIPTION:
# Some packages are so big they come on multiple CDs.  When you're done reading
# files off a CD and want access to the next one, just call this function.
# Again, all the messy details of user interaction are taken care of for you.
# Once this returns, just read the variable CDROM_ROOT for the location of the
# mounted CD.  Note that you can only go forward in the CD list, so make sure
# you only call this function when you're done using the current CD.
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
	local showedmsg=0 showjolietmsg=0

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
				[[ " cd9660 iso9660 udf " != *" ${fs} "* ]] && \
					! [[ ${fs} == "subfs" && ",${opts}," == *",fs=cdfss,"* ]] \
					&& continue
				point=${point//\040/ }
				[[ ! -d ${point}/${dir} ]] && continue
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
		if [[ ${showjolietmsg} -eq 0 ]] ; then
			showjolietmsg=1
		else
			ewarn "If you are having trouble with the detection"
			ewarn "of your CD, it is possible that you do not have"
			ewarn "Joliet support enabled in your kernel.  Please"
			ewarn "check that CONFIG_JOLIET is enabled in your kernel."
			ebeep 5
		fi
		read || die "something is screwed with your system"
	done
}

# @FUNCTION: strip-linguas
# @USAGE: [<allow LINGUAS>|<-i|-u> <directories of .po files>]
# @DESCRIPTION:
# Make sure that LINGUAS only contains languages that
# a package can support.  The first form allows you to
# specify a list of LINGUAS.  The -i builds a list of po
# files found in all the directories and uses the
# intersection of the lists.  The -u builds a list of po
# files found in all the directories and uses the union
# of the lists.
strip-linguas() {
	local ls newls nols
	if [[ $1 == "-i" ]] || [[ $1 == "-u" ]] ; then
		local op=$1; shift
		ls=$(find "$1" -name '*.po' -exec basename {} .po ';'); shift
		local d f
		for d in "$@" ; do
			if [[ ${op} == "-u" ]] ; then
				newls=${ls}
			else
				newls=""
			fi
			for f in $(find "$d" -name '*.po' -exec basename {} .po ';') ; do
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
		&& ewarn "Sorry, but ${PN} does not support the LINGUAS:" ${nols}
	export LINGUAS=${newls:1}
}

# @FUNCTION: preserve_old_lib
# @USAGE: <libs to preserve> [more libs]
# @DESCRIPTION:
# These functions are useful when a lib in your package changes ABI SONAME.
# An example might be from libogg.so.0 to libogg.so.1.  Removing libogg.so.0
# would break packages that link against it.  Most people get around this
# by using the portage SLOT mechanism, but that is not always a relevant
# solution, so instead you can call this from pkg_preinst.  See also the
# preserve_old_lib_notify function.
preserve_old_lib() {
	if [[ ${EBUILD_PHASE} != "preinst" ]] ; then
		eerror "preserve_old_lib() must be called from pkg_preinst() only"
		die "Invalid preserve_old_lib() usage"
	fi
	[[ -z $1 ]] && die "Usage: preserve_old_lib <library to preserve> [more libraries to preserve]"

	# let portage worry about it
	has preserve-libs ${FEATURES} && return 0

	# cannot preserve-libs on aix yet.
	[[ ${CHOST} == *-aix* ]] && {
		einfo "Not preserving libs on AIX (yet), not implemented."
		return 0
	}

	local lib dir
	for lib in "$@" ; do
		[[ -e ${EROOT}/${lib} ]] || continue
		dir=${lib%/*}
		dodir ${dir} || die "dodir ${dir} failed"
		cp "${EROOT}"/${lib} "${ED}"/${lib} || die "cp ${lib} failed"
		touch "${ED}"/${lib}
	done
}

# @FUNCTION: preserve_old_lib_notify
# @USAGE: <libs to notify> [more libs]
# @DESCRIPTION:
# Spit helpful messages about the libraries preserved by preserve_old_lib.
preserve_old_lib_notify() {
	if [[ ${EBUILD_PHASE} != "postinst" ]] ; then
		eerror "preserve_old_lib_notify() must be called from pkg_postinst() only"
		die "Invalid preserve_old_lib_notify() usage"
	fi

	# let portage worry about it
	has preserve-libs ${FEATURES} && return 0

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
	if [[ ${notice} -eq 1 ]] ; then
		ewarn
		ewarn "Once you've finished running revdep-rebuild, it should be safe to"
		ewarn "delete the old libraries.  Here is a copy & paste for the lazy:"
		for lib in "$@" ; do
			ewarn "  # rm '${lib}'"
		done
	fi
}

# @FUNCTION: built_with_use
# @USAGE: [--hidden] [--missing <action>] [-a|-o] <DEPEND ATOM> <List of USE flags>
# @DESCRIPTION:
#
# Deprecated: Use EAPI 2 use deps in DEPEND|RDEPEND and with has_version calls.
#
# A temporary hack until portage properly supports DEPENDing on USE
# flags being enabled in packages.  This will check to see if the specified
# DEPEND atom was built with the specified list of USE flags.  The
# --missing option controls the behavior if called on a package that does
# not actually support the defined USE flags (aka listed in IUSE).
# The default is to abort (call die).  The -a and -o flags control
# the requirements of the USE flags.  They correspond to "and" and "or"
# logic.  So the -a flag means all listed USE flags must be enabled
# while the -o flag means at least one of the listed IUSE flags must be
# enabled.  The --hidden option is really for internal use only as it
# means the USE flag we're checking is hidden expanded, so it won't be found
# in IUSE like normal USE flags.
#
# Remember that this function isn't terribly intelligent so order of optional
# flags matter.
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
		local IUSE_BUILT=( $(<"${IUSEFILE}") )
		# Don't check USE_EXPAND #147237
		local expand
		for expand in $(echo ${USE_EXPAND} | tr '[:upper:]' '[:lower:]') ; do
			if [[ $1 == ${expand}_* ]] ; then
				expand=""
				break
			fi
		done
		if [[ -n ${expand} ]] ; then
			if ! has $1 ${IUSE_BUILT[@]#[-+]} ; then
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

# @FUNCTION: epunt_cxx
# @USAGE: [dir to scan]
# @DESCRIPTION:
# Many configure scripts wrongly bail when a C++ compiler could not be
# detected.  If dir is not specified, then it defaults to ${S}.
#
# http://bugs.gentoo.org/73450
epunt_cxx() {
	local dir=$1
	[[ -z ${dir} ]] && dir=${S}
	ebegin "Removing useless C++ checks"
	local f
	find "${dir}" -name configure | while read f ; do
		patch --no-backup-if-mismatch -p0 "${f}" "${PORTDIR}/eclass/ELT-patches/nocxx/nocxx.patch" > /dev/null
	done
	eend 0
}

# @FUNCTION: make_wrapper
# @USAGE: <wrapper> <target> [chdir] [libpaths] [installpath]
# @DESCRIPTION:
# Create a shell wrapper script named wrapper in installpath
# (defaults to the bindir) to execute target (default of wrapper) by
# first optionally setting LD_LIBRARY_PATH to the colon-delimited
# libpaths followed by optionally changing directory to chdir.
make_wrapper() {
	local wrapper=$1 bin=$2 chdir=$3 libdir=$4 path=$5
	local tmpwrapper=$(emktemp)
	# We don't want to quote ${bin} so that people can pass complex
	# things as $bin ... "./someprog --args"
	cat << EOF > "${tmpwrapper}"
#!${EPREFIX}/bin/sh
cd "${chdir:-.}"
if [ -n "${libdir}" ] ; then
	if [ "\${LD_LIBRARY_PATH+set}" = "set" ] ; then
		export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:${EPREFIX}${libdir}"
	else
		export LD_LIBRARY_PATH="${EPREFIX}${libdir}"
	fi
	# ultra-dirty, just do the same for Darwin
	if [ "\${DYLD_LIBRARY_PATH+set}" = "set" ] ; then
		export DYLD_LIBRARY_PATH="\${DYLD_LIBRARY_PATH}:${EPERFIX}${libdir}"
	else
		export DYLD_LIBRARY_PATH="${EPREFIX}${libdir}"
	fi
fi
exec "${EPREFIX}"${bin} "\$@"
EOF
	chmod go+rx "${tmpwrapper}"
	if [[ -n ${path} ]] ; then
		(
		exeinto "${path}"
		newexe "${tmpwrapper}" "${wrapper}"
		) || die
	else
		newbin "${tmpwrapper}" "${wrapper}" || die
	fi
}

# @FUNCTION: prepalldocs
# @USAGE:
# @DESCRIPTION:
# Compress files in /usr/share/doc which are not already
# compressed, excluding /usr/share/doc/${PF}/html.
# Uses the ecompressdir to do the compression.
# 2009-02-18 by betelgeuse:
# Commented because ecompressdir is even more internal to
# Portage than prepalldocs (it's not even mentioned in man 5
# ebuild). Please submit a better version for review to gentoo-dev
# if you want prepalldocs here.
#prepalldocs() {
#	if [[ -n $1 ]] ; then
#		ewarn "prepalldocs: invalid usage; takes no arguments"
#	fi

#	cd "${ED}"
#	[[ -d usr/share/doc ]] || return 0

#	find usr/share/doc -exec gzip {} +
#	ecompressdir --ignore /usr/share/doc/${PF}/html
#	ecompressdir --queue /usr/share/doc
#}
