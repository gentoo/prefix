# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/linux-info.eclass,v 1.50 2006/12/07 18:52:55 dsd Exp $
#
# Description: This eclass is used as a central eclass for accessing kernel
#			   related information for sources already installed.
#			   It is vital for linux-mod to function correctly, and is split
#			   out so that any ebuild behaviour "templates" are abstracted out
#			   using additional eclasses.
#
# Maintainer: John Mylchreest <johnm@gentoo.org>
# Copyright 2004 Gentoo Linux
#
# Please direct your bugs to the current eclass maintainer :)

# A Couple of env vars are available to effect usage of this eclass
# These are as follows:
#
# Env Var	Option		Description
# KERNEL_DIR	<string>	The directory containing kernel the target kernel
#				sources.
# CONFIG_CHECK	<string>	a list of .config options to check for before
#				proceeding with the install. ie: CONFIG_CHECK="MTRR"
#				You can also check that an option doesn't exist by
#				prepending it with an exclamation mark (!).
#				ie: CONFIG_CHECK="!MTRR"
#				To simply warn about a missing option, prepend a '~'.
# ERROR_CFG		<string>	The error message to display when the above check
#				fails. <CFG> should reference the appropriate option
#				as above. ie: ERROR_MTRR="MTRR exists in the .config
#				but shouldn't!!"
# KBUILD_OUTPUT	<string>	This is passed on commandline, or can be set from
#				the kernel makefile. This contains the directory
#				which is to be used as the kernel object directory.

# There are also a couple of variables which are set by this, and shouldn't be
# set by hand. These are as follows:
#
# Env Var		Option		Description
# KV_FULL		<string>	The full kernel version. ie: 2.6.9-gentoo-johnm-r1
# KV_MAJOR		<integer>	The kernel major version. ie: 2
# KV_MINOR		<integer>	The kernel minor version. ie: 6
# KV_PATCH		<integer>	The kernel patch version. ie: 9
# KV_EXTRA		<string>	The kernel EXTRAVERSION. ie: -gentoo
# KV_LOCAL		<string>	The kernel LOCALVERSION concatenation. ie: -johnm
# KV_DIR		<string>	The kernel source directory, will be null if
#					KERNEL_DIR is invalid.
# KV_OUT_DIR		<string>	The kernel object directory. will be KV_DIR unless
#					koutput is used. This should be used for referencing
#					.config.

# And to ensure all the weirdness with crosscompile
inherit toolchain-funcs versionator

EXPORT_FUNCTIONS pkg_setup

DEPEND="kernel_linux? ( virtual/linux-sources )"
RDEPEND=""

# Overwritable environment Var's
# ---------------------------------------
KERNEL_DIR="${KERNEL_DIR:-${ROOT}usr/src/linux}"


# Bug fixes
# fix to bug #75034
case ${ARCH} in
	ppc)	BUILD_FIXES="${BUILD_FIXES} TOUT=${T}/.tmp_gas_check";;
	ppc64)	BUILD_FIXES="${BUILD_FIXES} TOUT=${T}/.tmp_gas_check";;
esac

# These are legacy wrappers for toolchain-funcs.
# I dont like them here, but oh well.
set_arch_to_kernel() { export ARCH="$(tc-arch-kernel)"; }
set_arch_to_portage() { export ARCH="$(tc-arch)"; }

# qeinfo "Message"
# -------------------
# qeinfo is a quiet einfo call when EBUILD_PHASE
# should not have visible output.
qout() {
	local outputmsg type
	type=${1}
	shift
	outputmsg="${@}"
	case "${EBUILD_PHASE}" in
		depend)  unset outputmsg;;
		clean)   unset outputmsg;;
		preinst) unset outputmsg;;
	esac
	[ -n "${outputmsg}" ] && ${type} "${outputmsg}"
}

qeinfo() { qout einfo "${@}" ; }
qeerror() { qout eerror "${@}" ; }

# File Functions
# ---------------------------------------

# getfilevar accepts 2 vars as follows:
# getfilevar <VARIABLE> <CONFIGFILE>

getfilevar() {
local	ERROR workingdir basefname basedname myARCH="${ARCH}"
	ERROR=0

	[ -z "${1}" ] && ERROR=1
	[ ! -f "${2}" ] && ERROR=1

	if [ "${ERROR}" = 1 ]
	then
		echo -e "\n"
		eerror "getfilevar requires 2 variables, with the second a valid file."
		eerror "   getfilevar <VARIABLE> <CONFIGFILE>"
	else
		workingdir="${PWD}"
		basefname="$(basename ${2})"
		basedname="$(dirname ${2})"
		unset ARCH

		cd "${basedname}"
		echo -e "e:\\n\\t@echo \$(${1})\\ninclude ${basefname}" | \
			make M="${S}" ${BUILD_FIXES} -s -f - 2>/dev/null
		cd "${workingdir}"

		ARCH=${myARCH}
	fi
}

linux_chkconfig_present() {
local	RESULT
	RESULT="$(getfilevar CONFIG_${1} ${KV_OUT_DIR}/.config)"
	[ "${RESULT}" = "m" -o "${RESULT}" = "y" ] && return 0 || return 1
}

linux_chkconfig_module() {
local	RESULT
	RESULT="$(getfilevar CONFIG_${1} ${KV_OUT_DIR}/.config)"
	[ "${RESULT}" = "m" ] && return 0 || return 1
}

linux_chkconfig_builtin() {
local	RESULT
	RESULT="$(getfilevar CONFIG_${1} ${KV_OUT_DIR}/.config)"
	[ "${RESULT}" = "y" ] && return 0 || return 1
}

linux_chkconfig_string() {
	getfilevar "CONFIG_${1}" "${KV_OUT_DIR}/.config"
}

# Versioning Functions
# ---------------------------------------

# kernel_is returns true when the version is the same as the passed version
#
# For Example where KV = 2.6.9
# kernel_is 2 4 	returns false
# kernel_is 2		returns true
# kernel_is 2 6		returns true
# kernel_is 2 6 8	returns false
# kernel_is 2 6 9	returns true
#
# got the jist yet?

kernel_is() {
	# if we haven't determined the version yet, we need too.
	get_version;
	local operator test value x=0 y=0 z=0

	case ${1} in
	  lt) operator="-lt"; shift;;
	  gt) operator="-gt"; shift;;
	  le) operator="-le"; shift;;
	  ge) operator="-ge"; shift;;
	  eq) operator="-eq"; shift;;
	   *) operator="-eq";;
	esac

	for x in ${@}; do
		for((y=0; y<$((3 - ${#x})); y++)); do value="${value}0"; done
		value="${value}${x}"
		z=$((${z} + 1))

		case ${z} in
		  1) for((y=0; y<$((3 - ${#KV_MAJOR})); y++)); do test="${test}0"; done;
		     test="${test}${KV_MAJOR}";;
		  2) for((y=0; y<$((3 - ${#KV_MINOR})); y++)); do test="${test}0"; done;
		     test="${test}${KV_MINOR}";;
		  3) for((y=0; y<$((3 - ${#KV_PATCH})); y++)); do test="${test}0"; done;
		     test="${test}${KV_PATCH}";;
		  *) die "Error in kernel-2_kernel_is(): Too many parameters.";;
		esac
	done

	[ ${test} ${operator} ${value} ] && return 0 || return 1
}

get_localversion() {
	local lv_list i x

	# ignore files with ~ in it.
	for i in $(ls ${1}/localversion* 2>/dev/null); do
		[[ -n ${i//*~*} ]] && lv_list="${lv_list} ${i}"
	done

	for i in ${lv_list}; do
		x="${x}$(<${i})"
	done
	x=${x/ /}
	echo ${x}
}

get_version() {
	local kbuild_output

	# no need to execute this twice assuming KV_FULL is populated.
	# we can force by unsetting KV_FULL
	[ -n "${KV_FULL}" ] && return 0

	# if we dont know KV_FULL, then we need too.
	# make sure KV_DIR isnt set since we need to work it out via KERNEL_DIR
	unset KV_DIR

	# KV_DIR will contain the full path to the sources directory we should use
	qeinfo "Determining the location of the kernel source code"
	[ -h "${KERNEL_DIR}" ] && KV_DIR="$(readlink -f ${KERNEL_DIR})"
	[ -d "${KERNEL_DIR}" ] && KV_DIR="${KERNEL_DIR}"

	if [ -z "${KV_DIR}" ]
	then
		qeerror "Unable to find kernel sources at ${KERNEL_DIR}"
		qeinfo "This package requires Linux sources."
		if [ "${KERNEL_DIR}" == "/usr/src/linux" ] ; then
			qeinfo "Please make sure that ${KERNEL_DIR} points at your running kernel, "
			qeinfo "(or the kernel you wish to build against)."
			qeinfo "Alternatively, set the KERNEL_DIR environment variable to the kernel sources location"
		else
			qeinfo "Please ensure that the KERNEL_DIR environment variable points at full Linux sources of the kernel you wish to compile against."
		fi
		return 1
	fi

	qeinfo "Found kernel source directory:"
	qeinfo "    ${KV_DIR}"

	if [ ! -s "${KV_DIR}/Makefile" ]
	then
		qeerror "Could not find a Makefile in the kernel source directory."
		qeerror "Please ensure that ${KERNEL_DIR} points to a complete set of Linux sources"
		return 1
	fi

	# OK so now we know our sources directory, but they might be using
	# KBUILD_OUTPUT, and we need this for .config and localversions-*
	# so we better find it eh?
	# do we pass KBUILD_OUTPUT on the CLI?
	OUTPUT_DIR="${OUTPUT_DIR:-${KBUILD_OUTPUT}}"

	# And if we didn't pass it, we can take a nosey in the Makefile
	kbuild_output="$(getfilevar KBUILD_OUTPUT ${KV_DIR}/Makefile)"
	OUTPUT_DIR="${OUTPUT_DIR:-${kbuild_output}}"

	# And contrary to existing functions I feel we shouldn't trust the
	# directory name to find version information as this seems insane.
	# so we parse ${KV_DIR}/Makefile
	KV_MAJOR="$(getfilevar VERSION ${KV_DIR}/Makefile)"
	KV_MINOR="$(getfilevar PATCHLEVEL ${KV_DIR}/Makefile)"
	KV_PATCH="$(getfilevar SUBLEVEL ${KV_DIR}/Makefile)"
	KV_EXTRA="$(getfilevar EXTRAVERSION ${KV_DIR}/Makefile)"

	if [ -z "${KV_MAJOR}" -o -z "${KV_MINOR}" -o -z "${KV_PATCH}" ]
	then
		qeerror "Could not detect kernel version."
		qeerror "Please ensure that ${KERNEL_DIR} points to a complete set of Linux sources."
		return 1
	fi

	# and in newer versions we can also pull LOCALVERSION if it is set.
	# but before we do this, we need to find if we use a different object directory.
	# This *WILL* break if the user is using localversions, but we assume it was
	# caught before this if they are.
	[ "${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${KV_EXTRA}" == "$(uname -r)" ] && \
		OUTPUT_DIR="${OUTPUT_DIR:-/lib/modules/${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${KV_EXTRA}/build}"

	[ -h "${OUTPUT_DIR}" ] && KV_OUT_DIR="$(readlink -f ${OUTPUT_DIR})"
	[ -d "${OUTPUT_DIR}" ] && KV_OUT_DIR="${OUTPUT_DIR}"
	if [ -n "${KV_OUT_DIR}" ];
	then
		qeinfo "Found kernel object directory:"
		qeinfo "    ${KV_OUT_DIR}"

		KV_LOCAL="$(get_localversion ${KV_OUT_DIR})"
	fi
	# and if we STILL have not got it, then we better just set it to KV_DIR
	KV_OUT_DIR="${KV_OUT_DIR:-${KV_DIR}}"

	if [ ! -s "${KV_OUT_DIR}/.config" ]
	then
		qeerror "Could not find a usable .config in the kernel source directory."
		qeerror "Please ensure that ${KERNEL_DIR} points to a configured set of Linux sources."
		qeerror "If you are using KBUILD_OUTPUT, please set the environment var so that"
		qeerror "it points to the necessary object directory so that it might find .config."
		return 1
	fi

	KV_LOCAL="${KV_LOCAL}$(get_localversion ${KV_DIR})"
	KV_LOCAL="${KV_LOCAL}$(linux_chkconfig_string LOCALVERSION)"
	KV_LOCAL="${KV_LOCAL//\"/}"

	# For things like git that can append extra stuff:
	[ -e ${KV_DIR}/scripts/setlocalversion ] &&
		linux_chkconfig_builtin LOCALVERSION_AUTO &&
		KV_LOCAL="${KV_LOCAL}$(sh ${KV_DIR}/scripts/setlocalversion ${KV_DIR})"

	# And we should set KV_FULL to the full expanded version
	KV_FULL="${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${KV_EXTRA}${KV_LOCAL}"

	qeinfo "Found sources for kernel version:"
	qeinfo "    ${KV_FULL}"

	return 0
}

get_running_version() {
	KV_FULL=$(uname -r)

	if [[ -f ${ROOT}/lib/modules/${KV_FULL}/source/Makefile ]]; then
		KERNEL_DIR=$(readlink -f ${ROOT}/lib/modules/${KV_FULL}/source)
		unset KV_FULL
		get_version
		return $?
	elif [[ -f ${ROOT}/lib/modules/${KV_FULL}/build/Makefile ]]; then
		KERNEL_DIR=$(readlink -f ${ROOT}/lib/modules/${KV_FULL}/build)
		unset KV_FULL
		get_version
		return $?
	else
		KV_MAJOR=$(get_version_component_range 1 ${KV_FULL})
		KV_MINOR=$(get_version_component_range 2 ${KV_FULL})
		KV_PATCH=$(get_version_component_range 3- ${KV_FULL})
		KV_PATCH=${KV_PATCH//-*}
		[[ -n ${KV_FULL#*-} ]] && [[ -n ${KV_FULL//${KV_FULL#*-}} ]] \
			&& KV_EXTRA="-${KV_FULL#*-}"
	fi
	return 0
}


# ebuild check functions
# ---------------------------------------

check_kernel_built() {
	# if we haven't determined the version yet, we need too.
	get_version;

	if [ ! -f "${KV_OUT_DIR}/include/linux/version.h" ]
	then
		eerror "These sources have not yet been prepared."
		eerror "We cannot build against an unprepared tree."
		eerror "To resolve this, please type the following:"
		eerror
		eerror "# cd ${KV_DIR}"
		eerror "# make oldconfig"
		eerror "# make modules_prepare"
		eerror
		eerror "Then please try merging this module again."
		die "Kernel sources need compiling first"
	fi
}

check_modules_supported() {
	# if we haven't determined the version yet, we need too.
	get_version;

	if ! linux_chkconfig_builtin "MODULES"
	then
		eerror "These sources do not support loading external modules."
		eerror "to be able to use this module please enable \"Loadable modules support\""
		eerror "in your kernel, recompile and then try merging this module again."
		die "No support for external modules in ${KV_FULL} config"
	fi
}

check_extra_config() {
	local	config negate die error reworkmodulenames
	local	soft_errors_count=0 hard_errors_count=0

	# if we haven't determined the version yet, we need too.
	get_version;

	einfo "Checking for suitable kernel configuration options..."
	for config in ${CONFIG_CHECK}
	do
		# if we specify any fatal, ensure we honor them
		die=1
		error=0
		negate=0
		reworkmodulenames=0

		if [[ -z ${config/\~*} ]]; then
			die=0
			config=${config:1}
		elif [[ -z ${config/\@*} ]]; then
			die=0
			reworkmodulenames=1
			config=${config:1}
		fi
		if [[ -z ${config//\!*} ]]; then
			negate=1
			config=${config:1}
		fi

		if [[ ${negate} == 1 ]]; then
			linux_chkconfig_present ${config} && error=2
		elif [[ ${reworkmodulenames} == 1 ]]; then
			local temp_config="${config//*:}" i n
			config="${config//:*}"
			if linux_chkconfig_present ${config}; then
				for i in ${MODULE_NAMES}; do
					n="${i//${temp_config}}"
					[[ -z ${n//\(*} ]] && \
						MODULE_IGNORE="${MODULE_IGNORE} ${temp_config}"
				done
				error=2
			fi
		else
			linux_chkconfig_present ${config} || error=1
		fi

		if [[ ${error} > 0 ]]; then
			local report_func="eerror" local_error
			local_error="ERROR_${config}"
			local_error="${!local_error}"

			if [[ -z "${local_error}" ]]; then
				# using old, deprecated format.
				local_error="${config}_ERROR"
				local_error="${!local_error}"
			fi
			if [[ ${die} == 0 && -z "${local_error}" ]]; then
				#soft errors can be warnings
				local_error="WARNING_${config}"
				local_error="${!local_error}"
				if [[ -n "${local_error}" ]] ; then
					report_func="ewarn"
				fi
			fi

			if [[ -z "${local_error}" ]]; then
				[[ ${error} == 1 ]] \
					&& local_error="is not set when it should be." \
					|| local_error="should not be set. But it is."
				local_error="CONFIG_${config}:\t ${local_error}"
			fi
			if [[ ${die} == 0 ]]; then
				${report_func} "  ${local_error}"
				soft_errors_count=$[soft_errors_count + 1]
			else
				${report_func} "  ${local_error}"
				hard_errors_count=$[hard_errors_count + 1]
			fi
		fi
	done

	if [[ ${hard_errors_count} > 0 ]]; then
		eerror "Please check to make sure these options are set correctly."
		eerror "Failure to do so may cause unexpected problems."
		eerror "Once you have satisfied these options, please try merging"
		eerror "this package again."
		die "Incorrect kernel configuration options"
	elif [[ ${soft_errors_count} > 0 ]]; then
		ewarn "Please check to make sure these options are set correctly."
		ewarn "Failure to do so may cause unexpected problems."
	else
		eend 0
	fi
}

check_zlibinflate() {
	# if we haven't determined the version yet, we need too.
	get_version;

	# although I restructured this code - I really really really dont support it!

	# bug #27882 - zlib routines are only linked into the kernel
	# if something compiled into the kernel calls them
	#
	# plus, for the cloop module, it appears that there's no way
	# to get cloop.o to include a static zlib if CONFIG_MODVERSIONS
	# is on

	local INFLATE
	local DEFLATE

	einfo "Determining the usability of ZLIB_INFLATE support in your kernel"

	ebegin "checking ZLIB_INFLATE"
	getfilevar_isbuiltin CONFIG_ZLIB_INFLATE ${KV_DIR}/.config
	eend $?
	[ "$?" != 0 ] && die

	ebegin "checking ZLIB_DEFLATE"
	getfilevar_isbuiltin CONFIG_ZLIB_DEFLATE ${KV_DIR}/.config
	eend $?
	[ "$?" != 0 ] && die

	local LINENO_START
	local LINENO_END
	local SYMBOLS
	local x

	LINENO_END="$(grep -n 'CONFIG_ZLIB_INFLATE y' ${KV_DIR}/lib/Config.in | cut -d : -f 1)"
	LINENO_START="$(head -n $LINENO_END ${KV_DIR}/lib/Config.in | grep -n 'if \[' | tail -n 1 | cut -d : -f 1)"
	(( LINENO_AMOUNT = $LINENO_END - $LINENO_START ))
	(( LINENO_END = $LINENO_END - 1 ))
	SYMBOLS="$(head -n $LINENO_END ${KV_DIR}/lib/Config.in | tail -n $LINENO_AMOUNT | sed -e 's/^.*\(CONFIG_[^\" ]*\).*/\1/g;')"

	# okay, now we have a list of symbols
	# we need to check each one in turn, to see whether it is set or not
	for x in $SYMBOLS ; do
		if [ "${!x}" = "y" ]; then
			# we have a winner!
			einfo "${x} ensures zlib is linked into your kernel - excellent"
			return 0
		fi
	done

	eerror
	eerror "This kernel module requires ZLIB library support."
	eerror "You have enabled zlib support in your kernel, but haven't enabled"
	eerror "enabled any option that will ensure that zlib is linked into your"
	eerror "kernel."
	eerror
	eerror "Please ensure that you enable at least one of these options:"
	eerror

	for x in $SYMBOLS ; do
		eerror "  * $x"
	done

	eerror
	eerror "Please remember to recompile and install your kernel, and reboot"
	eerror "into your new kernel before attempting to load this kernel module."

	die "Kernel doesn't include zlib support"
}

################################
# Default pkg_setup
# Also used when inheriting linux-mod to force a get_version call

linux-info_pkg_setup() {
	get_version || die "Unable to calculate Linux Kernel version"

	if kernel_is 2 4; then
		if [ "$( gcc-major-version )" -eq "4" ] ; then
			echo
			ewarn "Be warned !! >=sys-devel/gcc-4.0.0 isn't supported with"
			ewarn "linux-2.4 (or modules building against a linux-2.4 kernel)!"
			echo
			ewarn "Either switch to another gcc-version (via gcc-config) or use a"
			ewarn "newer kernel that supports gcc-4."
			echo
			ewarn "Also be aware that bugreports about gcc-4 not working"
			ewarn "with linux-2.4 based ebuilds will be closed as INVALID!"
			echo
			epause 10
		fi
	fi

	[ -n "${CONFIG_CHECK}" ] && check_extra_config;
}
