# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/linux-mod.eclass,v 1.70 2007/01/01 22:27:01 swegener Exp $

# Description: This eclass is used to interface with linux-info in such a way
#              to provide the functionality required and initial functions
#			   required to install external modules against a kernel source
#			   tree.
#
# Maintainer: John Mylchreest <johnm@gentoo.org>, Stefan Schweizer <genstef@gentoo.org>
# Copyright 2004 Gentoo Linux
#
# Please direct your bugs to the current eclass maintainer :)

# A Couple of env vars are available to effect usage of this eclass
# These are as follows:
#
# Env Var		Option		Default		Description
# KERNEL_DIR		<string>	/usr/src/linux	The directory containing kernel
#							the target kernel sources.
# ECONF_PARAMS		<string>			The parameters to pass to econf.
#							If this is not set, then econf
#							isn't run.
# BUILD_PARAMS		<string>			The parameters to pass to emake.
# BUILD_TARGETS		<string>	clean modules	The build targets to pass to
#							make.
# MODULE_NAMES		<string>			This is the modules which are
#							to be built automatically using
#							the default pkg_compile/install.
#							They are explained properly
#							below. It will only make
#							BUILD_TARGETS once in any
#							directory.

# MODULE_NAMES - Detailed Overview
#
# The structure of each MODULE_NAMES entry is as follows:
# modulename(libdir:srcdir:objdir)
# for example:
# MODULE_NAMES="module_pci(pci:${S}/pci:${S}) module_usb(usb:${S}/usb:${S})"
#
# what this would do is
#  cd ${S}/pci
#  make ${BUILD_PARAMS} ${BUILD_TARGETS}
#  cd ${S}
#  insinto /lib/modules/${KV_FULL}/pci
#  doins module_pci.${KV_OBJ}
#
#  cd ${S}/usb
#  make ${BUILD_PARAMS} ${BUILD_TARGETS}
#  cd ${S}
#  insinto /lib/modules/${KV_FULL}/usb
#  doins module_usb.${KV_OBJ}
#
# if the srcdir isnt specified, it assumes ${S}
# if the libdir isnt specified, it assumes misc.
# if the objdir isnt specified, it assumes srcdir

# There is also support for automatyed modules.d file generation.
# This can be explicitly enabled by setting any of the following variables.
#
#
# MODULESD_${modulename}_ENABLED		This enables the modules.d file
#						generation even if we dont
#						specify any additional info.
# MODULESD_${modulename}_EXAMPLES		This is a bash array containing
#						a list of examples which should
#						be used. If you want us to try and
#						take a guess. Set this to "guess"
# MODULESD_${modulename}_ALIASES		This is a bash array containing
#						a list of associated aliases.
# MODULESD_${modulename}_ADDITIONS		This is a bash array containing
#						A list of additional things to
#						add to the bottom of the file.
#						This can be absolutely anything.
#						Each entry is a new line.
# MODULES_${modulename}_DOCS			This is a string list which contains
#						the full path to any associated
#						documents for $modulename

# The order of these is important as both of linux-info and eutils contain
# set_arch_to_kernel and set_arch_to_portage functions and the ones in eutils
# are deprecated in favor of the ones in linux-info.
# See http://bugs.gentoo.org/show_bug.cgi?id=127506

inherit eutils linux-info multilib
EXPORT_FUNCTIONS pkg_setup pkg_preinst pkg_postinst src_install src_compile pkg_postrm

IUSE="kernel_linux"
SLOT="0"
DESCRIPTION="Based on the $ECLASS eclass"
RDEPEND="kernel_linux? ( virtual/modutils )"
DEPEND="${RDEPEND}
	sys-apps/sed"

# eclass utilities
# ----------------------------------

check_vermagic() {
	debug-print-function ${FUNCNAME} $*

	local curr_gcc_ver=$(gcc -dumpversion)
	local tmpfile old_chost old_gcc_ver result=0

	tmpfile=`find ${KV_DIR}/ -iname "*.o.cmd" -exec grep usr/lib/gcc {} \; -quit`
	tmpfile=${tmpfile//*usr/lib}
	tmpfile=${tmpfile//\/include*}
	old_chost=${tmpfile//*gcc\/}
	old_chost=${old_chost//\/*}
	old_gcc_ver=${tmpfile//*\/}

	if [[ -z ${old_gcc_ver} || -z ${old_chost} ]]; then
		ewarn ""
		ewarn "Unable to detect what version of GCC was used to compile"
		ewarn "the kernel. Build will continue, but you may experience problems."
	elif [[ ${curr_gcc_ver} != ${old_gcc_ver} ]]; then
		ewarn ""
		ewarn "The version of GCC you are using (${curr_gcc_ver}) does"
		ewarn "not match the version of GCC used to compile the"
		ewarn "kernel (${old_gcc_ver})."
		result=1
	elif [[ ${CHOST} != ${old_chost} ]]; then
		ewarn ""
		ewarn "The current CHOST (${CHOST}) does not match the chost"
		ewarn "used when compiling the kernel (${old_chost})."
		result=1
	fi

	if [[ ${result} -gt 0 ]]; then
		ewarn ""
		ewarn "Build will not continue, because you will experience problems."
		ewarn "To fix this either change the version of GCC you wish to use"
		ewarn "to match the kernel, or recompile the kernel first."
		die "GCC Version Mismatch."
	fi
}

use_m() {
	debug-print-function ${FUNCNAME} $*

	# if we haven't determined the version yet, we need too.
	get_version;

	# if the kernel version is greater than 2.6.6 then we should use
	# M= instead of SUBDIRS=
	[ ${KV_MAJOR} -eq 2 -a ${KV_MINOR} -gt 5 -a ${KV_PATCH} -gt 5 ] && \
		return 0 || return 1
}

convert_to_m() {
	debug-print-function ${FUNCNAME} $*

	if use_m
	then
		[ ! -f "${1}" ] && \
			die "convert_to_m() requires a filename as an argument"
		ebegin "Converting ${1/${WORKDIR}\//} to use M= instead of SUBDIRS="
		sed -i 's:SUBDIRS=:M=:g' ${1}
		eend $?
	fi
}

update_depmod() {
	debug-print-function ${FUNCNAME} $*

	# if we haven't determined the version yet, we need too.
	get_version;

	ebegin "Updating module dependencies for ${KV_FULL}"
	if [ -r ${KV_OUT_DIR}/System.map ]
	then
		depmod -ae -F ${KV_OUT_DIR}/System.map -b ${EROOT} -r ${KV_FULL}
		eend $?
	else
		ewarn
		ewarn "${KV_OUT_DIR}/System.map not found."
		ewarn "You must manually update the kernel module dependencies using depmod."
		eend 1
		ewarn
	fi
}

update_modules() {
	debug-print-function ${FUNCNAME} $*

	if [ -x /sbin/modules-update ] && \
		grep -v -e "^#" -e "^$" ${ED}/etc/modules.d/* >/dev/null 2>&1; then
		ebegin "Updating modules.conf"
		/sbin/modules-update
		eend $?
	fi
}

move_old_moduledb() {
	debug-print-function ${FUNCNAME} $*

	local OLDDIR=${EROOT}/usr/share/module-rebuild/
	local NEWDIR=${EROOT}/var/lib/module-rebuild/

	if [[ -f ${OLDDIR}/moduledb ]]; then
		[[ ! -d ${NEWDIR} ]] && mkdir -p ${NEWDIR}
		[[ ! -f ${NEWDIR}/moduledb ]] && \
			mv ${OLDDIR}/moduledb ${NEWDIR}/moduledb
		rm -f ${OLDDIR}/*
		rmdir ${OLDDIR}
	fi
}

update_moduledb() {
	debug-print-function ${FUNCNAME} $*

	local MODULEDB_DIR=${EROOT}/var/lib/module-rebuild/
	move_old_moduledb

	if [[ ! -f ${MODULEDB_DIR}/moduledb ]]; then
		[[ ! -d ${MODULEDB_DIR} ]] && mkdir -p ${MODULEDB_DIR}
		touch ${MODULEDB_DIR}/moduledb
	fi
	if [[ -z $(grep ${CATEGORY}/${PN}-${PVR} ${MODULEDB_DIR}/moduledb) ]]; then
		einfo "Adding module to moduledb."
		echo "a:1:${CATEGORY}/${PN}-${PVR}" >> ${MODULEDB_DIR}/moduledb
	fi
}

remove_moduledb() {
	debug-print-function ${FUNCNAME} $*

	local MODULEDB_DIR=${EROOT}/var/lib/module-rebuild/
	move_old_moduledb

	if [[ -n $(grep ${CATEGORY}/${PN}-${PVR} ${MODULEDB_DIR}/moduledb) ]]; then
		einfo "Removing ${CATEGORY}/${PN}-${PVR} from moduledb."
		sed -ie "/.*${CATEGORY}\/${PN}-${PVR}.*/d" ${MODULEDB_DIR}/moduledb
	fi
}

set_kvobj() {
	debug-print-function ${FUNCNAME} $*

	if kernel_is 2 6
	then
		KV_OBJ="ko"
	else
		KV_OBJ="o"
	fi
	# Do we really need to know this?
	# Lets silence it.
	# einfo "Using KV_OBJ=${KV_OBJ}"
}

get-KERNEL_CC() {
	debug-print-function ${FUNCNAME} $*

	local kernel_cc
	if [ -n "${KERNEL_ABI}" ]; then
		# In future, an arch might want to define CC_$ABI
		#kernel_cc="$(get_abi_CC)"
		#[ -z "${kernel_cc}" ] &&
		kernel_cc="$(tc-getCC $(ABI=${KERNEL_ABI} get_abi_CHOST))"
	else
		kernel_cc=$(tc-getCC)
	fi
	echo "${kernel_cc}"
}

generate_modulesd() {
	debug-print-function ${FUNCNAME} $*

	# This function will generate the neccessary modules.d file from the
	# information contained in the modules exported parms

	local 	currm_path currm currm_t t myIFS myVAR
	local 	module_docs module_enabled module_aliases \
			module_additions module_examples module_modinfo module_opts

	for currm_path in ${@}
	do
		currm=${currm_path//*\/}
		currm=$(echo ${currm} | tr '[:lower:]' '[:upper:]')
		currm_t=${currm}
		while [[ -z ${currm_t//*-*} ]]; do
			currm_t=${currm_t/-/_}
		done

		module_docs="$(eval echo \${MODULESD_${currm_t}_DOCS})"
		module_enabled="$(eval echo \${MODULESD_${currm_t}_ENABLED})"
		module_aliases="$(eval echo \${#MODULESD_${currm_t}_ALIASES[*]})"
		module_additions="$(eval echo \${#MODULESD_${currm_t}_ADDITIONS[*]})"
		module_examples="$(eval echo \${#MODULESD_${currm_t}_EXAMPLES[*]})"

		[[ ${module_aliases} -eq 0 ]] 	&& unset module_aliases
		[[ ${module_additions} -eq 0 ]]	&& unset module_additions
		[[ ${module_examples} -eq 0 ]] 	&& unset module_examples

		# If we specify we dont want it, then lets exit, otherwise we assume
		# that if its set, we do want it.
		[[ ${module_enabled} == no ]] && return 0

		# unset any unwanted variables.
		for t in ${!module_*}
		do
			[[ -z ${!t} ]] && unset ${t}
		done

		[[ -z ${!module_*} ]] && return 0

		# OK so now if we have got this far, then we know we want to continue
		# and generate the modules.d file.
		module_modinfo="$(modinfo -p ${currm_path}.${KV_OBJ})"
		module_config="${T}/modulesd-${currm}"

		ebegin "Preparing file for modules.d"
		#-----------------------------------------------------------------------
		echo "# modules.d configuration file for ${currm}" >> ${module_config}
		#-----------------------------------------------------------------------
		[[ -n ${module_docs} ]] && \
			echo "# For more information please read:" >> ${module_config}
		for t in ${module_docs}
		do
			echo "#    ${t//*\/}" >> ${module_config}
		done
		echo >> ${module_config}

		#-----------------------------------------------------------------------
		if [[ ${module_aliases} -gt 0 ]]
		then
			echo  "# Internal Aliases - Do not edit" >> ${module_config}
			echo  "# ------------------------------" >> ${module_config}

			for((t=0; t<${module_aliases}; t++))
			do
				echo "alias $(eval echo \${MODULESD_${currm}_ALIASES[$t]})" \
					>> ${module_config}
			done
			echo '' >> ${module_config}
		fi

		#-----------------------------------------------------------------------
		if [[ -n ${module_modinfo} ]]
		then
			echo >> ${module_config}
			echo  "# Configurable module parameters" >> ${module_config}
			echo  "# ------------------------------" >> ${module_config}
			myIFS="${IFS}"
			IFS="$(echo -en "\n\b")"

			for t in ${module_modinfo}
			do
				myVAR="$(echo ${t#*:} | grep -e " [0-9][ =]" | sed "s:.*\([01][= ]\).*:\1:")"
				if [[ -n ${myVAR} ]]
				then
					module_opts="${module_opts} ${t%%:*}:${myVAR}"
				fi
				echo -e "# ${t%%:*}:\t${t#*:}" >> ${module_config}
			done
			IFS="${myIFS}"
			echo '' >> ${module_config}
		fi

		#-----------------------------------------------------------------------
		if [[ $(eval echo \${MODULESD_${currm}_ALIASES[0]}) == guess ]]
		then
			# So lets do some guesswork eh?
			if [[ -n ${module_opts} ]]
			then
				echo "# For Example..." >> ${module_config}
				echo "# --------------" >> ${module_config}
				for t in ${module_opts}
				do
					echo "# options ${currm} ${t//:*}=${t//*:}" >> ${module_config}
				done
				echo '' >> ${module_config}
			fi
		elif [[ ${module_examples} -gt 0 ]]
		then
			echo "# For Example..." >> ${module_config}
			echo "# --------------" >> ${module_config}
			for((t=0; t<${module_examples}; t++))
			do
				echo "options $(eval echo \${MODULESD_${currm}_EXAMPLES[$t]})" \
					>> ${module_config}
			done
			echo '' >> ${module_config}
		fi

		#-----------------------------------------------------------------------
		if [[ ${module_additions} -gt 0 ]]
		then
			for((t=0; t<${module_additions}; t++))
			do
				echo "$(eval echo \${MODULESD_${currm}_ADDITIONS[$t]})" \
					>> ${module_config}
			done
			echo '' >> ${module_config}
		fi

		#-----------------------------------------------------------------------

		# then we install it
		insinto /etc/modules.d
		newins ${module_config} ${currm_path//*\/}

		# and install any documentation we might have.
		[[ -n ${module_docs} ]] && dodoc ${module_docs}
	done
	eend 0
	return 0
}

find_module_params() {
	debug-print-function ${FUNCNAME} $*

	local matched_offset=0 matched_opts=0 test="${@}" temp_var result
	local i=0 y=0 z=0

	for((i=0; i<=${#test}; i++))
	do
		case ${test:${i}:1} in
			\()		matched_offset[0]=${i};;
			\:)		matched_opts=$((${matched_opts} + 1));
					matched_offset[${matched_opts}]="${i}";;
			\))		matched_opts=$((${matched_opts} + 1));
					matched_offset[${matched_opts}]="${i}";;
		esac
	done

	for((i=0; i<=${matched_opts}; i++))
	do
		# i			= offset were working on
		# y			= last offset
		# z			= current offset - last offset
		# temp_var	= temporary name
		case ${i} in
			0)	tempvar=${test:0:${matched_offset[0]}};;
			*)	y=$((${matched_offset[$((${i} - 1))]} + 1))
				z=$((${matched_offset[${i}]} - ${matched_offset[$((${i} - 1))]}));
				z=$((${z} - 1))
				tempvar=${test:${y}:${z}};;
		esac

		case ${i} in
			0)	result="${result} modulename:${tempvar}";;
			1)	result="${result} libdir:${tempvar}";;
			2)	result="${result} srcdir:${tempvar}";;
			3)	result="${result} objdir:${tempvar}";;
		esac
	done

	echo ${result}
}

# default ebuild functions
# --------------------------------

linux-mod_pkg_setup() {
	debug-print-function ${FUNCNAME} $*

	linux-info_pkg_setup;
	check_kernel_built;
	strip_modulenames;
	[[ -n ${MODULE_NAMES} ]] && check_modules_supported
	set_kvobj;
	# Commented out with permission from johnm until a fixed version for arches
	# who intentionally use different kernel and userland compilers can be
	# introduced - Jason Wever <weeve@gentoo.org>, 23 Oct 2005
	#check_vermagic;
}

strip_modulenames() {
	debug-print-function ${FUNCNAME} $*

	local i
	for i in ${MODULE_IGNORE}; do
		MODULE_NAMES=${MODULE_NAMES//${i}(*}
	done
}

linux-mod_src_compile() {
	debug-print-function ${FUNCNAME} $*

	local modulename libdir srcdir objdir i n myARCH="${ARCH}" myABI="${ABI}"
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"

	BUILD_TARGETS=${BUILD_TARGETS:-clean module}
	strip_modulenames;
	for i in ${MODULE_NAMES}
	do
		unset libdir srcdir objdir
		for n in $(find_module_params ${i})
		do
			eval ${n/:*}=${n/*:/}
		done
		libdir=${libdir:-misc}
		srcdir=${srcdir:-${S}}
		objdir=${objdir:-${srcdir}}

		if [ ! -f "${srcdir}/.built" ];
		then
			cd ${srcdir}
			einfo "Preparing ${modulename} module"
			if [[ -n ${ECONF_PARAMS} ]]
			then
				econf ${ECONF_PARAMS} || \
				die "Unable to run econf ${ECONF_PARAMS}"
			fi

			emake HOSTCC="$(tc-getBUILD_CC)" CC="$(get-KERNEL_CC)" LDFLAGS="$(get_abi_LDFLAGS)" \
				  ${BUILD_FIXES} ${BUILD_PARAMS} ${BUILD_TARGETS} \
				|| die "Unable to make ${BUILD_FIXES} ${BUILD_PARAMS} ${BUILD_TARGETS}."
			touch ${srcdir}/.built
			cd ${OLDPWD}
		fi
	done

	ARCH="${myARCH}"
	ABI="${myABI}"
}

linux-mod_src_install() {
	debug-print-function ${FUNCNAME} $*

	local modulename libdir srcdir objdir i n

	strip_modulenames;
	for i in ${MODULE_NAMES}
	do
		unset libdir srcdir objdir
		for n in $(find_module_params ${i})
		do
			eval ${n/:*}=${n/*:/}
		done
		libdir=${libdir:-misc}
		srcdir=${srcdir:-${S}}
		objdir=${objdir:-${srcdir}}

		einfo "Installing ${modulename} module"
		cd ${objdir} || die "${objdir} does not exist"
		insinto /lib/modules/${KV_FULL}/${libdir}
		doins ${modulename}.${KV_OBJ} || die "doins ${modulename}.${KV_OBJ} failed"
		cd ${OLDPWD}

		generate_modulesd ${objdir}/${modulename}
	done
}

linux-mod_pkg_preinst() {
	debug-print-function ${FUNCNAME} $*

	[ -d ${IMAGE}/lib/modules ] && UPDATE_DEPMOD=true || UPDATE_DEPMOD=false
	[ -d ${IMAGE}/etc/modules.d ] && UPDATE_MODULES=true || UPDATE_MODULES=false
	[ -d ${IMAGE}/lib/modules ] && UPDATE_MODULEDB=true || UPDATE_MODULEDB=false
}

linux-mod_pkg_postinst() {
	debug-print-function ${FUNCNAME} $*

	${UPDATE_DEPMOD} && update_depmod;
	${UPDATE_MODULES} && update_modules;
	${UPDATE_MODULEDB} && update_moduledb;
}

linux-mod_pkg_postrm() {
	debug-print-function ${FUNCNAME} $*
	remove_moduledb;
}
