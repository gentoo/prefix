# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kernel-2.eclass,v 1.197 2006/10/26 06:55:31 vapier Exp $

# Description: kernel.eclass rewrite for a clean base regarding the 2.6
#              series of kernel with back-compatibility for 2.4
#
# Maintainer: John Mylchreest <johnm@gentoo.org>
#
# Please direct your bugs to the current eclass maintainer :)

# added functionality:
# unipatch		- a flexible, singular method to extract, add and remove patches.

# A Couple of env vars are available to effect usage of this eclass
# These are as follows:
#
# K_USEPV				- When setting the EXTRAVERSION variable, it should
#						  add PV to the end.
#						  this is useful for thigns like wolk. IE:
#						  EXTRAVERSION would be something like : -wolk-4.19-r1
# K_NOSETEXTRAVERSION	- if this is set then EXTRAVERSION will not be
#						  automatically set within the kernel Makefile
# K_NOUSENAME			- if this is set then EXTRAVERSION will not include the
#						  first part of ${PN} in EXTRAVERSION
# K_NOUSEPR				- if this is set then EXTRAVERSION will not include the
#						  anything based on ${PR}.
# K_PREPATCHED			- if the patchset is prepatched (ie: mm-sources,
#						  ck-sources, ac-sources) it will use PR (ie: -r5) as
#						  the patchset version for
#						  and not use it as a true package revision
# K_EXTRAEINFO			- this is a new-line seperated list of einfo displays in
#						  postinst and can be used to carry additional postinst
#						  messages
# K_EXTRAEWARN			- same as K_EXTRAEINFO except ewarn's instead of einfo's
# K_SYMLINK				- if this is set, then forcably create symlink anyway
#
# K_DEFCONFIG			- Allow specifying a different defconfig target.
#						  If length zero, defaults to "defconfig".
# K_WANT_GENPATCHES		- Apply genpatches to kernel source. Provide any
# 						  combination of "base" and "extras"
# K_GENPATCHES_VER		- The version of the genpatches tarball(s) to apply.
#						  A value of "5" would apply genpatches-2.6.12-5 to
#						  my-sources-2.6.12.ebuild

# H_SUPPORTEDARCH		- this should be a space separated list of ARCH's which
#						  can be supported by the headers ebuild

# UNIPATCH_LIST			- space delimetered list of patches to be applied to the
#						  kernel
# UNIPATCH_EXCLUDE		- an addition var to support exlusion based completely
#						  on "<passedstring>*" and not "<passedno#>_*"
#						- this should _NOT_ be used from the ebuild as this is
#						  reserved for end users passing excludes from the cli
# UNIPATCH_DOCS			- space delimemeted list of docs to be installed to
#						  the doc dir
# UNIPATCH_STRICTORDER	- if this is set places patches into directories of
#						  order, so they are applied in the order passed

inherit eutils toolchain-funcs versionator multilib
EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst pkg_postinst

# Added by Daniel Ostrow <dostrow@gentoo.org>
# This is an ugly hack to get around an issue with a 32-bit userland on ppc64.
# I will remove it when I come up with something more reasonable.
[[ ${PROFILE_ARCH} == "ppc64" ]] && CHOST="powerpc64-${CHOST#*-}"

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} && ${CATEGORY/cross-} != ${CATEGORY} ]]; then
	export CTARGET=${CATEGORY/cross-}
fi

HOMEPAGE="http://www.kernel.org/ http://www.gentoo.org/ ${HOMEPAGE}"
LICENSE="GPL-2"

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="binchecks strip"

# set LINUX_HOSTCFLAGS if not already set
[[ -z ${LINUX_HOSTCFLAGS} ]] && \
	LINUX_HOSTCFLAGS="-Wall -Wstrict-prototypes -Os -fomit-frame-pointer -I${S}/include"

# debugging functions
#==============================================================
# this function exists only to help debug kernel-2.eclass
# if you are adding new functionality in, put a call to it
# at the start of src_unpack, or during SRC_URI/dep generation.
debug-print-kernel2-variables() {
	debug-print "PVR: ${PVR}"
	debug-print "CKV: ${CKV}"
	debug-print "OKV: ${OKV}"
	debug-print "KV: ${KV}"
	debug-print "KV_FULL: ${KV_FULL}"
	debug-print "RELEASETYPE: ${RELEASETYPE}"
	debug-print "RELEASE: ${RELEASE}"
	debug-print "UNIPATCH_LIST_DEFAULT: ${UNIPATCH_LIST_DEFAULT} "
	debug-print "UNIPATCH_LIST_GENPATCHES: ${UNIPATCH_LIST_GENPATCHES} "
	debug-print "UNIPATCH_LIST: ${UNIPATCH_LIST}"
	debug-print "S: ${S}"
	debug-print "KERNEL_URI: ${KERNEL_URI}"
}

#Eclass functions only from here onwards ...
#==============================================================
handle_genpatches() {
	local tarball
	[[ -z ${K_WANT_GENPATCHES} || -z ${K_GENPATCHES_VER} ]] && return -1

	for i in ${K_WANT_GENPATCHES} ; do
		tarball="genpatches-${OKV}-${K_GENPATCHES_VER}.${i}.tar.bz2"
		GENPATCHES_URI="${GENPATCHES_URI} mirror://gentoo/${tarball}"
		UNIPATCH_LIST_GENPATCHES="${UNIPATCH_LIST_GENPATCHES} ${DISTDIR}/${tarball}"
	done
}

detect_version() {
	# this function will detect and set
	# - OKV: Original Kernel Version (2.6.0/2.6.0-test11)
	# - KV: Kernel Version (2.6.0-gentoo/2.6.0-test11-gentoo-r1)
	# - EXTRAVERSION: The additional version appended to OKV (-gentoo/-gentoo-r1)

	if [[ -n ${KV_FULL} ]]; then
		# we will set this for backwards compatibility.
		KV=${KV_FULL}

		# we know KV_FULL so lets stop here. but not without resetting S
		S=${WORKDIR}/linux-${KV_FULL}
		return
	fi

	# CKV is used as a comparison kernel version, which is used when
	# PV doesnt reflect the genuine kernel version.
	# this gets set to the portage style versioning. ie:
	#   CKV=2.6.11_rc4
	CKV=${CKV:-${PV}}
	OKV=${OKV:-${CKV}}
	OKV=${OKV/_beta/-test}
	OKV=${OKV/_rc/-rc}
	OKV=${OKV/-r*}
	OKV=${OKV/_p*}

	KV_MAJOR=$(get_version_component_range 1 ${OKV})
	KV_MINOR=$(get_version_component_range 2 ${OKV})
	KV_PATCH=$(get_version_component_range 3 ${OKV})

	if [[ ${KV_MAJOR}${KV_MINOR}${KV_PATCH} -ge 269 ]]; then
		KV_EXTRA=$(get_version_component_range 4- ${OKV})
		KV_EXTRA=${KV_EXTRA/[-_]*}
	else
		KV_PATCH=$(get_version_component_range 3- ${OKV})
	fi
	KV_PATCH=${KV_PATCH/[-_]*}

	KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"

	RELEASE=${CKV/${OKV}}
	RELEASE=${RELEASE/_beta}
	RELEASE=${RELEASE/_rc/-rc}
	RELEASE=${RELEASE/_pre/-pre}
	kernel_is ge 2 6 && RELEASE=${RELEASE/-pre/-git}
	RELEASETYPE=${RELEASE//[0-9]}

	# Now we know that RELEASE is the -rc/-git
	# and RELEASETYPE is the same but with its numerics stripped
	# we can work on better sorting EXTRAVERSION.
	# first of all, we add the release
	EXTRAVERSION="${RELEASE}"
	debug-print "0 EXTRAVERSION:${EXTRAVERSION}"
	[[ -n ${KV_EXTRA} ]] && EXTRAVERSION=".${KV_EXTRA}${EXTRAVERSION}"

	debug-print "1 EXTRAVERSION:${EXTRAVERSION}"
	if [[ -n "${K_NOUSEPR}" ]]; then
		# Don't add anything based on PR to EXTRAVERSION
		debug-print "1.0 EXTRAVERSION:${EXTRAVERSION}"
	elif [[ -n ${K_PREPATCHED} ]]; then
		debug-print "1.1 EXTRAVERSION:${EXTRAVERSION}"
		EXTRAVERSION="${EXTRAVERSION}-${PN/-*}${PR/r}"
	elif [[ "${ETYPE}" = "sources" ]]; then
		debug-print "1.2 EXTRAVERSION:${EXTRAVERSION}"
		# For some sources we want to use the PV in the extra version
		# This is because upstream releases with a completely different
		# versioning scheme.
		case ${PN/-*} in
		     wolk) K_USEPV=1;;
		  vserver) K_USEPV=1;;
		esac

		[[ -z "${K_NOUSENAME}" ]] && EXTRAVERSION="${EXTRAVERSION}-${PN/-*}"
		[[ -n "${K_USEPV}" ]]     && EXTRAVERSION="${EXTRAVERSION}-${PV//_/-}"
		[[ -n "${PR//r0}" ]] && EXTRAVERSION="${EXTRAVERSION}-${PR}"
	fi
	debug-print "2 EXTRAVERSION:${EXTRAVERSION}"

	# The only messing around which should actually effect this is for KV_EXTRA
	# since this has to limit OKV to MAJ.MIN.PAT and strip EXTRA off else
	# KV_FULL evaluates to MAJ.MIN.PAT.EXT.EXT after EXTRAVERSION
	if [[ -n ${KV_EXTRA} ]]; then
		OKV="${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"
		KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/patch-${CKV}.bz2
					mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}.tar.bz2"
		UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${CKV}.bz2"
	fi

	# We need to set this using OKV, but we need to set it before we do any
	# messing around with OKV based on RELEASETYPE
	KV_FULL=${OKV}${EXTRAVERSION}

	# we will set this for backwards compatibility.
	S=${WORKDIR}/linux-${KV_FULL}
	KV=${KV_FULL}

	# -rc-git pulls can be achieved by specifying CKV
	# for example:
	#   CKV="2.6.11_rc3_pre2"
	# will pull:
	#   linux-2.6.10.tar.bz2 & patch-2.6.11-rc3.bz2 & patch-2.6.11-rc3-git2.bz2

	if [[ ${RELEASETYPE} == -rc ]] || [[ ${RELEASETYPE} == -pre ]]; then
		OKV="${KV_MAJOR}.${KV_MINOR}.$((${KV_PATCH} - 1))"
		KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/testing/patch-${CKV//_/-}.bz2
					mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"
		UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${CKV//_/-}.bz2"
	fi

	if [[ ${RELEASETYPE} == -git ]]; then
		KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/snapshots/patch-${OKV}${RELEASE}.bz2
					mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"
		UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${OKV}${RELEASE}.bz2"
	fi

	if [[ ${RELEASETYPE} == -rc-git ]]; then
		OKV="${KV_MAJOR}.${KV_MINOR}.$((${KV_PATCH} - 1))"
		KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/snapshots/patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${RELEASE}.bz2
					mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/testing/patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${RELEASE/-git*}.bz2
					mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"
		UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${RELEASE/-git*}.bz2 ${DISTDIR}/patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}${RELEASE}.bz2"
	fi

	debug-print-kernel2-variables

	handle_genpatches
}

kernel_is() {
	[[ -z ${OKV} ]] && detect_version
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

kernel_is_2_4() {
	kernel_is 2 4
}

kernel_is_2_6() {
	kernel_is 2 6 || kernel_is 2 5
}

# Capture the sources type and set DEPENDs
if [[ ${ETYPE} == sources ]]; then
	DEPEND="!build? ( sys-apps/sed
					  >=sys-devel/binutils-2.11.90.0.31 )"
	RDEPEND="!build? ( >=sys-libs/ncurses-5.2
			           sys-devel/make )
			 virtual/dev-manager"

	PROVIDE="virtual/linux-sources"
	kernel_is gt 2 4 && PROVIDE="${PROVIDE} virtual/alsa"

	SLOT="${PVR}"
	DESCRIPTION="Sources for the ${KV_MAJOR}.${KV_MINOR} linux kernel"
	IUSE="symlink build"
elif [[ ${ETYPE} == headers ]]; then
	DESCRIPTION="Linux system headers"

	# Since we should NOT honour KBUILD_OUTPUT in headers
	# lets unset it here.
	unset KBUILD_OUTPUT

	if [[ ${CTARGET} = ${CHOST} ]]; then
		DEPEND="!virtual/os-headers"
		PROVIDE="virtual/os-headers"
		SLOT="0"
	else
		SLOT="${CTARGET}"
	fi
else
	eerror "Unknown ETYPE=\"${ETYPE}\", must be \"sources\" or \"headers\""
	die "Unknown ETYPE=\"${ETYPE}\", must be \"sources\" or \"headers\""
fi

# Cross-compile support functions
#==============================================================
kernel_header_destdir() {
	[[ ${CTARGET} == ${CHOST} ]] \
		&& echo /usr/include \
		|| echo /usr/${CTARGET}/usr/include
}

cross_pre_c_headers() {
	use crosscompile_opts_headers-only && [[ ${CHOST} != ${CTARGET} ]]
}

env_setup_xmakeopts() {
	# Kernel ARCH != portage ARCH
	export KARCH=$(tc-arch-kernel)

	# When cross-compiling, we need to set the ARCH/CROSS_COMPILE
	# variables properly or bad things happen !
	xmakeopts="ARCH=${KARCH}"
	if [[ ${CTARGET} != ${CHOST} ]] && ! cross_pre_c_headers ; then
		xmakeopts="${xmakeopts} CROSS_COMPILE=${CTARGET}-"
	elif type -p ${CHOST}-ar > /dev/null ; then
		xmakeopts="${xmakeopts} CROSS_COMPILE=${CHOST}-"
	fi
	export xmakeopts
}

# Unpack functions
#==============================================================
unpack_2_4() {
	# this file is required for other things to build properly,
	# so we autogenerate it
	make -s mrproper ${xmakeopts} || die "make mrproper failed"
	make -s symlinks ${xmakeopts} || die "make symlinks failed"
	make -s include/linux/version.h ${xmakeopts} || die "make include/linux/version.h failed"
	echo ">>> version.h compiled successfully."
}

unpack_2_6() {
	# this file is required for other things to build properly, so we
	# autogenerate it ... generate a .config to keep version.h build from
	# spitting out an annoying warning
	make -s mrproper ${xmakeopts} 2>/dev/null \
		|| die "make mrproper failed"

	# quick fix for bug #132152 which triggers when it cannot include linux
	# headers (ie, we have not installed it yet)
	if ! make -s defconfig ${xmakeopts} &>/dev/null 2>&1 ; then
		touch .config
		eerror "make defconfig failed."
		eerror "assuming you dont have any headers installed yet and continuing"
		epause 5
	fi

	make -s include/linux/version.h ${xmakeopts} 2>/dev/null \
		|| die "make include/linux/version.h failed"
	rm -f .config >/dev/null
}

universal_unpack() {
	cd ${WORKDIR}
	unpack linux-${OKV}.tar.bz2
	if [[ -d "linux" ]]; then
		mv linux linux-${KV_FULL} \
			|| die "Unable to move source tree to ${KV_FULL}."
	elif [[ "${OKV}" != "${KV_FULL}" ]]; then
		mv linux-${OKV} linux-${KV_FULL} \
			|| die "Unable to move source tree to ${KV_FULL}."
	fi
	cd "${S}"

	# remove all backup files
	find . -iname "*~" -exec rm {} \; 2> /dev/null

	# fix a problem on ppc where TOUT writes to /usr/src/linux breaking sandbox
	sed -i \
		-e 's|TOUT	:= .tmp_gas_check|TOUT	:= $(T).tmp_gas_check|' \
		"${S}"/arch/ppc/Makefile
}

unpack_set_extraversion() {
	cd "${S}"
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile
	cd "${OLDPWD}"
}

# Should be done after patches have been applied
# Otherwise patches that modify the same area of Makefile will fail
unpack_fix_install_path() {
	cd "${S}"
	sed	-i -e 's:#export\tINSTALL_PATH:export\tINSTALL_PATH:' Makefile
}

# Compile Functions
#==============================================================
compile_headers() {
	env_setup_xmakeopts

	# if we couldnt obtain HOSTCFLAGS from the Makefile,
	# then set it to something sane
	local HOSTCFLAGS=$(getfilevar HOSTCFLAGS "${S}"/Makefile)
	HOSTCFLAGS=${HOSTCFLAGS:--Wall -Wstrict-prototypes -O2 -fomit-frame-pointer}

	if kernel_is 2 4; then
		yes "" | make oldconfig ${xmakeopts}
		echo ">>> make oldconfig complete"
		make dep ${xmakeopts}
	elif kernel_is 2 6; then
		# 2.6.18 introduces headers_install which means we dont need any
		# of this crap anymore :D
		kernel_is ge 2 6 18 && return 0

		# autoconf.h isnt generated unless it already exists. plus, we have
		# no guarantee that any headers are installed on the system...
		[[ -f ${ROOT}/usr/include/linux/autoconf.h ]] \
			|| touch include/linux/autoconf.h

		# if K_DEFCONFIG isn't set, force to "defconfig"
		# needed by mips
		if [[ -z ${K_DEFCONFIG} ]]; then
			if [[ $(KV_to_int ${KV}) -ge $(KV_to_int 2.6.16) ]]; then
				case ${CTARGET} in
					powerpc64*)	K_DEFCONFIG="ppc64_defconfig";;
					powerpc*)	K_DEFCONFIG="pmac32_defconfig";;
					*)			K_DEFCONFIG="defconfig";;
				esac
			else
				K_DEFCONFIG="defconfig"
			fi
		fi

		# if there arent any installed headers, then there also isnt an asm
		# symlink in /usr/include/, and make defconfig will fail, so we have
		# to force an include path with $S.
		HOSTCFLAGS="${HOSTCFLAGS} -I${S}/include/"
		ln -sf asm-${KARCH} "${S}"/include/asm
		cross_pre_c_headers && return 0

		make ${K_DEFCONFIG} HOSTCFLAGS="${HOSTCFLAGS}" ${xmakeopts} || die "defconfig failed (${K_DEFCONFIG})"
		if compile_headers_tweak_config ; then
			yes "" | make oldconfig HOSTCFLAGS="${HOSTCFLAGS}" ${xmakeopts} || die "2nd oldconfig failed"
		fi
		make prepare HOSTCFLAGS="${HOSTCFLAGS}" ${xmakeopts} || die "prepare failed"
		make prepare-all HOSTCFLAGS="${HOSTCFLAGS}" ${xmakeopts} || die "prepare failed"
	fi
}

compile_headers_tweak_config() {
	# some targets can be very very picky, so let's finesse the
	# .config based upon any info we may have
	case ${CTARGET} in
	sh*)
		sed -i '/CONFIG_CPU_SH/d' .config
		echo "CONFIG_CPU_SH${CTARGET:2:1}=y" >> .config
		return 0;;
	esac

	# no changes, so lets do nothing
	return 1
}

# install functions
#==============================================================
install_universal() {
	#fix silly permissions in tarball
	cd ${WORKDIR}
	chown -R root:0 *
	chmod -R a+r-w+X,u+w *
	cd ${OLDPWD}
}

install_headers() {
	local ddir=$(kernel_header_destdir)

	# 2.6.18 introduces headers_install which means we dont need any
	# of this crap anymore :D
	if kernel_is ge 2 6 18 ; then
		env_setup_xmakeopts
		emake headers_install INSTALL_HDR_PATH="${D}"/${ddir}/.. ${xmakeopts} || die

		# let other packages install some of these headers
		rm -rf "${D}"/${ddir}/sound #alsa-headers
		rm -rf "${D}"/${ddir}/scsi  #glibc/uclibc/etc...
		return 0
	fi

	cd "${S}"
	dodir ${ddir}/linux
	cp -pPR "${S}"/include/linux/* ${D}/${ddir}/linux
	rm -rf ${D}/${ddir}/linux/modules

	# Handle multilib headers and crap
	local multi_dirs="" multi_defs=""
	case $(tc-arch-kernel) in
		sparc64)
			multi_dirs="sparc sparc64"
			multi_defs="!__arch64__ __arch64__"
			;;
		x86_64)
			multi_dirs="i386 x86_64"
			multi_defs="__i386__ __x86_64__"
			;;
		ppc64)
			multi_dirs="ppc ppc64"
			multi_defs="!__powerpc64__ __powerpc64__"
			;;
		s390x)
			multi_dirs="s390 s390x"
			multi_defs="!__s390x__ __s390x__"
			;;
		arm)
			dodir ${ddir}/asm
			cp -pPR "${S}"/include/asm/* "${D}"/${ddir}/asm
			[[ ! -e ${D}/${ddir}/asm/arch ]] && ln -sf arch-ebsa285 "${D}"/${ddir}/asm/arch
			[[ ! -e ${D}/${ddir}/asm/proc ]] && ln -sf proc-armv "${D}"/${ddir}/asm/proc
			;;
		powerpc)
			dodir ${ddir}/asm
			cp -pPR "${S}"/include/asm/* ${D}/${ddir}/asm
			if [[ -e "${S}"/include/asm-ppc ]] ; then
				dodir ${ddir}/asm-ppc
				cp -pPR "${S}"/include/asm-ppc/* ${D}/${ddir}/asm-ppc
			fi
			;;
		*)
			dodir ${ddir}/asm
			cp -pPR "${S}"/include/asm/* ${D}/${ddir}/asm
			;;
	esac
	if [[ -n ${multi_dirs} ]] ; then
		local d ml_inc=""
		for d in ${multi_dirs} ; do
			dodir ${ddir}/asm-${d}
			cp -pPR "${S}"/include/asm-${d}/* ${D}/${ddir}/asm-${d}/ || die "cp asm-${d} failed"

			ml_inc="${ml_inc} ${multi_defs%% *}:${ddir}/asm-${d}"
			multi_defs=${multi_defs#* }
		done
		create_ml_includes ${ddir}/asm ${ml_inc}
	fi

	if kernel_is 2 6; then
		dodir ${ddir}/asm-generic
		cp -pPR "${S}"/include/asm-generic/* ${D}/${ddir}/asm-generic
	fi

	# clean up
	find "${D}" -name '*.orig' -exec rm -f {} \;

	cd ${OLDPWD}
}

install_sources() {
	local file

	cd "${S}"
	dodir /usr/src
	echo ">>> Copying sources ..."

	file="$(find ${WORKDIR} -iname "docs" -type d)"
	if [[ -n ${file} ]]; then
		for file in $(find ${file} -type f); do
			echo "${file//*docs\/}" >> "${S}"/patches.txt
			echo "===================================================" >> "${S}"/patches.txt
			cat ${file} >> "${S}"/patches.txt
			echo "===================================================" >> "${S}"/patches.txt
			echo "" >> "${S}"/patches.txt
		done
	fi

	if [[ ! -f ${S}/patches.txt ]]; then
		# patches.txt is empty so lets use our ChangeLog
		[[ -f ${FILESDIR}/../ChangeLog ]] && \
			echo "Please check the ebuild ChangeLog for more details." \
			> "${S}"/patches.txt
	fi

	mv ${WORKDIR}/linux* ${D}/usr/src
}

# pkg_preinst functions
#==============================================================
preinst_headers() {
	local ddir=$(kernel_header_destdir)
	[[ -L ${ddir}/linux ]] && rm ${ddir}/linux
	[[ -L ${ddir}/asm ]] && rm ${ddir}/asm
}

# pkg_postinst functions
#==============================================================
postinst_sources() {
	local MAKELINK=0

	# if we have USE=symlink, then force K_SYMLINK=1
	use symlink && K_SYMLINK=1

	# if we are to forcably symlink, delete it if it already exists first.
	if [[ ${K_SYMLINK} > 0 ]]; then
		[[ -h ${ROOT}usr/src/linux ]] && rm ${ROOT}usr/src/linux
		MAKELINK=1
	fi

	# if the link doesnt exist, lets create it
	[[ ! -h ${ROOT}usr/src/linux ]] && MAKELINK=1

	if [[ ${MAKELINK} == 1 ]]; then
		cd ${ROOT}usr/src
		ln -sf linux-${KV_FULL} linux
		cd ${OLDPWD}
	fi

	# Don't forget to make directory for sysfs
	[[ ! -d ${ROOT}sys ]] && kernel_is 2 6 && mkdir ${ROOT}sys

	echo
	einfo "After installing a new kernel of any version, it is important"
	einfo "that you have the appropriate /etc/modules.autoload.d/kernel-X.Y"
	einfo "created (X.Y is the first 2 parts of your new kernel version)"
	echo
	einfo "For example, this kernel will require:"
	einfo "/etc/modules.autoload.d/kernel-${KV_MAJOR}.${KV_MINOR}"
	echo
	einfo "If you are upgrading from a previous kernel, you may be interested"
	einfo "in the following documents:"
	einfo "  - General upgrade guide: http://www.gentoo.org/doc/en/kernel-upgrade.xml"
	kernel_is_2_6 && einfo "  - 2.4 to 2.6 migration guide: http://www.gentoo.org/doc/en/migration-to-2.6.xml"
	if kernel_is ge 2 6 13; then
		ewarn "As of 2.6.13 the support for devfs has been removed."
		ewarn "You will be required to either manage a static /dev"
		ewarn "or to ensure that udev is starting on boot."
	fi
	echo

	# if K_EXTRAEINFO is set then lets display it now
	if [[ -n ${K_EXTRAEINFO} ]]; then
		echo ${K_EXTRAEINFO} | fmt |
		while read -s ELINE; do	einfo "${ELINE}"; done
	fi

	# if K_EXTRAEWARN is set then lets display it now
	if [[ -n ${K_EXTRAEWARN} ]]; then
		echo ${K_EXTRAEWARN} | fmt |
		while read -s ELINE; do ewarn "${ELINE}"; done
	fi
}

postinst_headers() {
	einfo "Kernel headers are usually only used when recompiling glibc, as such, following the installation"
	einfo "of newer headers, it is advised that you re-merge glibc as follows:"
	einfo "emerge glibc"
	einfo "Failure to do so will cause glibc to not make use of newer features present in the updated kernel"
	einfo "headers."
}

# pkg_setup functions
#==============================================================
setup_headers() {
	[[ -z ${H_SUPPORTEDARCH} ]] && H_SUPPORTEDARCH=${PN/-*/}
	for i in ${H_SUPPORTEDARCH}; do
		[[ $(tc-arch) == "${i}" ]] && H_ACCEPT_ARCH="yes"
	done

	if [[ ${H_ACCEPT_ARCH} != "yes" ]]; then
		echo
		eerror "This version of ${PN} does not support $(tc-arch)."
		eerror "Please merge the appropriate sources, in most cases"
		eerror "(but not all) this will be called $(tc-arch)-headers."
		die "Package unsupported for $(tc-arch)"
	fi
}

# unipatch
#==============================================================
unipatch() {
	local i x y z extention PIPE_CMD UNIPATCH_DROP KPATCH_DIR PATCH_DEPTH ELINE
	local STRICT_COUNT PATCH_LEVEL myLC_ALL myLANG

	# set to a standard locale to ensure sorts are ordered properly.
	myLC_ALL="${LC_ALL}"
	myLANG="${LANG}"
	LC_ALL="C"
	LANG=""

	[ -z "${KPATCH_DIR}" ] && KPATCH_DIR="${WORKDIR}/patches/"
	[ ! -d ${KPATCH_DIR} ] && mkdir -p ${KPATCH_DIR}

	# We're gonna need it when doing patches with a predefined patchlevel
	shopt -s extglob

	# This function will unpack all passed tarballs, add any passed patches, and remove any passed patchnumbers
	# usage can be either via an env var or by params
	# although due to the nature we pass this within this eclass
	# it shall be by param only.
	# -z "${UNIPATCH_LIST}" ] && UNIPATCH_LIST="${@}"
	UNIPATCH_LIST="${@}"

	#unpack any passed tarballs
	for i in ${UNIPATCH_LIST}; do
		if [ -n "$(echo ${i} | grep -e "\.tar" -e "\.tbz" -e "\.tgz")" ]; then
			extention=${i/*./}
			extention=${extention/:*/}
			case ${extention} in
				tbz2) PIPE_CMD="tar -xvjf";;
				 bz2) PIPE_CMD="tar -xvjf";;
				 tgz) PIPE_CMD="tar -xvzf";;
				  gz) PIPE_CMD="tar -xvzf";;
				   *) eerror "Unrecognized tarball compression"
				      die "Unrecognized tarball compression";;
			esac

			if [ -n "${UNIPATCH_STRICTORDER}" ]; then
				unset z
				STRICT_COUNT=$((10#${STRICT_COUNT} + 1))
				for((y=0; y<$((6 - ${#STRICT_COUNT})); y++));
					do z="${z}0";
				done
				PATCH_ORDER="${z}${STRICT_COUNT}"

				mkdir -p ${KPATCH_DIR}/${PATCH_ORDER}/
				${PIPE_CMD} ${i/:*/} -C ${KPATCH_DIR}/${PATCH_ORDER}/ 1>/dev/null
			else
				${PIPE_CMD} ${i/:*/} -C ${KPATCH_DIR} 1>/dev/null
			fi

			if [ $? == 0 ]; then
				einfo "${i/*\//} unpacked"
				[ -n "$(echo ${i} | grep ':')" ] && echo ">>> Strict patch levels not currently supported for tarballed patchsets"
			else
				eerror "Failed to unpack ${i/:*/}"
				die "unable to unpack patch tarball"
			fi
		else
			extention=${i/*./}
			extention=${extention/:*/}
			PIPE_CMD=""
			case ${extention} in
				    bz2) PIPE_CMD="bzip2 -dc";;
				  patch) PIPE_CMD="cat";;
				   diff) PIPE_CMD="cat";;
				 gz|Z|z) PIPE_CMD="gzip -dc";;
				ZIP|zip) PIPE_CMD="unzip -p";;
				      *) UNIPATCH_DROP="${UNIPATCH_DROP} ${i/:*/}";;
			esac

			PATCH_LEVEL=${i/*([^:])?(:)}
			i=${i/:*/}
			x=${i/*\//}
			x=${x/\.${extention}/}

			if [ -n "${PIPE_CMD}" ]; then
				if [ ! -r "${i}" ]; then
					echo
					eerror "FATAL: unable to locate:"
					eerror "${i}"
					eerror "for read-only. The file either has incorrect permissions"
					eerror "or does not exist."
					die Unable to locate ${i}
				fi

				if [ -n "${UNIPATCH_STRICTORDER}" ]; then
					unset z
					STRICT_COUNT=$((10#${STRICT_COUNT} + 1))
					for((y=0; y<$((6 - ${#STRICT_COUNT})); y++));
						do z="${z}0";
					done
					PATCH_ORDER="${z}${STRICT_COUNT}"

					mkdir -p ${KPATCH_DIR}/${PATCH_ORDER}/
					$(${PIPE_CMD} ${i} > ${KPATCH_DIR}/${PATCH_ORDER}/${x}.patch${PATCH_LEVEL})
				else
					$(${PIPE_CMD} ${i} > ${KPATCH_DIR}/${x}.patch${PATCH_LEVEL})
				fi
			fi
		fi
	done

	#populate KPATCH_DIRS so we know where to look to remove the excludes
	x=${KPATCH_DIR}
	KPATCH_DIR=""
	for i in $(find ${x} -type d | sort -n); do
		KPATCH_DIR="${KPATCH_DIR} ${i}"
	done

	#so now lets get rid of the patchno's we want to exclude
	UNIPATCH_DROP="${UNIPATCH_EXCLUDE} ${UNIPATCH_DROP}"
	for i in ${UNIPATCH_DROP}; do
		ebegin "Excluding Patch #${i}"
		for x in ${KPATCH_DIR}; do rm -f ${x}/${i}* 2>/dev/null; done
		eend $?
	done

	# and now, finally, we patch it :)
	for x in ${KPATCH_DIR}; do
		for i in $(find ${x} -maxdepth 1 -iname "*.patch*" -or -iname "*.diff*" | sort -n); do
			STDERR_T="${T}/${i/*\//}"
			STDERR_T="${STDERR_T/.patch*/.err}"

			[ -z ${i/*.patch*/} ] && PATCH_DEPTH=${i/*.patch/}
			#[ -z ${i/*.diff*/} ]  && PATCH_DEPTH=${i/*.diff/}

			if [ -z "${PATCH_DEPTH}" ]; then PATCH_DEPTH=0; fi

			ebegin "Applying ${i/*\//} (-p${PATCH_DEPTH}+)"
			while [ ${PATCH_DEPTH} -lt 5 ]; do
				echo "Attempting Dry-run:" >> ${STDERR_T}
				echo "cmd: patch -p${PATCH_DEPTH} --dry-run -f < ${i}" >> ${STDERR_T}
				echo "=======================================================" >> ${STDERR_T}
				if [ $(patch -p${PATCH_DEPTH} --dry-run -f < ${i} >> ${STDERR_T}) $? -eq 0 ]; then
					echo "Attempting patch:" > ${STDERR_T}
					echo "cmd: patch -p${PATCH_DEPTH} -f < ${i}" >> ${STDERR_T}
					echo "=======================================================" >> ${STDERR_T}
					if [ $(patch -p${PATCH_DEPTH} -f < ${i} >> ${STDERR_T}) "$?" -eq 0 ]; then
						eend 0
						rm ${STDERR_T}
						break
					else
						eend 1
						eerror "Failed to apply patch ${i/*\//}"
						eerror "Please attach ${STDERR_T} to any bug you may post."
						die "Failed to apply ${i/*\//}"
					fi
				else
					PATCH_DEPTH=$((${PATCH_DEPTH} + 1))
				fi
			done
			if [ ${PATCH_DEPTH} -eq 5 ]; then
				eend 1
				eerror "Please attach ${STDERR_T} to any bug you may post."
				die "Unable to dry-run patch."
			fi
		done
	done

	# This is a quick, and kind of nasty hack to deal with UNIPATCH_DOCS which
	# sit in KPATCH_DIR's. This is handled properly in the unipatch rewrite,
	# which is why I'm not taking too much time over this.
	local tmp
	for i in ${UNIPATCH_DOCS}; do
		tmp="${tmp} ${i//*\/}"
		cp -f ${i} ${T}/
	done
	UNIPATCH_DOCS="${tmp}"

	# clean up  KPATCH_DIR's - fixes bug #53610
	for x in ${KPATCH_DIR}; do rm -Rf ${x}; done

	LC_ALL="${myLC_ALL}"
	LANG="${myLANG}"
}

# getfilevar accepts 2 vars as follows:
# getfilevar <VARIABLE> <CONFIGFILE>
# pulled from linux-info

getfilevar() {
	local workingdir basefname basedname xarch=$(tc-arch-kernel)

	if [[ -z ${1} ]] && [[ ! -f ${2} ]]; then
		echo -e "\n"
		eerror "getfilevar requires 2 variables, with the second a valid file."
		eerror "   getfilevar <VARIABLE> <CONFIGFILE>"
	else
		workingdir=${PWD}
		basefname=$(basename ${2})
		basedname=$(dirname ${2})
		unset ARCH

		cd ${basedname}
		echo -e "include ${basefname}\ne:\n\t@echo \$(${1})" | \
			make ${BUILD_FIXES} -s -f - e 2>/dev/null
		cd ${workingdir}

		ARCH=${xarch}
	fi
}

detect_arch() {
	# This function sets ARCH_URI and ARCH_PATCH
	# with the neccessary info for the arch sepecific compatibility
	# patchsets.

	local ALL_ARCH LOOP_ARCH COMPAT_URI i

	# COMPAT_URI is the contents of ${ARCH}_URI
	# ARCH_URI is the URI for all the ${ARCH}_URI patches
	# ARCH_PATCH is ARCH_URI broken into files for UNIPATCH

	ARCH_URI=""
	ARCH_PATCH=""
	ALL_ARCH="ALPHA AMD64 ARM HPPA IA64 M68K MIPS PPC PPC64 S390 SH SPARC X86"

	for LOOP_ARCH in ${ALL_ARCH}; do
		COMPAT_URI="${LOOP_ARCH}_URI"
		COMPAT_URI="${!COMPAT_URI}"

		[[ -n ${COMPAT_URI} ]] && \
			ARCH_URI="${ARCH_URI} $(echo ${LOOP_ARCH} | tr '[:upper:]' '[:lower:]')? ( ${COMPAT_URI} )"

		if [[ ${LOOP_ARCH} == "$(echo $(tc-arch-kernel) | tr '[:lower:]' '[:upper:]')" ]]; 	then
			for i in ${COMPAT_URI}; do
				ARCH_PATCH="${ARCH_PATCH} ${DISTDIR}/${i/*\//}"
			done
		fi
	done
}

# sparc nastiness
#==============================================================
# This script generates the files in /usr/include/asm for sparc systems
# during installation of sys-kernel/linux-headers.
# Will no longer be needed when full 64 bit support is used on sparc64
# systems.
#
# Shamefully ripped from Debian
# ----------------------------------------------------------------------

# Idea borrowed from RedHat's kernel package

# This is gonna get replaced by something in multilib.eclass soon...
# --eradicator
generate_sparc_asm() {
	local name

	cd $1 || die
	mkdir asm

	for h in `( ls asm-sparc; ls asm-sparc64 ) | grep '\.h$' | sort -u`; do
		name="$(echo $h | tr a-z. A-Z_)"
		# common header
		echo "/* All asm/ files are generated and point to the corresponding
 * file in asm-sparc or asm-sparc64.
 */

#ifndef __SPARCSTUB__${name}__
#define __SPARCSTUB__${name}__
" > asm/${h}

		# common for sparc and sparc64
		if [ -f asm-sparc/$h -a -f asm-sparc64/$h ]; then
			echo "#ifdef __arch64__
#include <asm-sparc64/$h>
#else
#include <asm-sparc/$h>
#endif
" >> asm/${h}

		# sparc only
		elif [ -f asm-sparc/$h ]; then
echo "#ifndef __arch64__
#include <asm-sparc/$h>
#endif
" >> asm/${h}

		# sparc64 only
		else
echo "#ifdef __arch64__
#include <asm-sparc64/$h>
#endif
" >> asm/${h}
		fi

		# common footer
		echo "#endif /* !__SPARCSTUB__${name}__ */" >> asm/${h}
	done
	return 0
}

headers___fix() {
	# Voodoo to partially fix broken upstream headers.
	# Issues with this function should go to toolchain.
	sed -i \
		-e '/^\#define.*_TYPES_H/{:loop n; bloop}' \
		-e 's:\<\([us]\(8\|16\|32\|64\)\)\>:__\1:g' \
		-e "s/ inline / __inline__ /g" \
		"$@"
}

# common functions
#==============================================================
kernel-2_src_unpack() {
	universal_unpack
	debug-print "Doing unipatch"

	[[ -n ${UNIPATCH_LIST} || -n ${UNIPATCH_LIST_DEFAULT} || -n ${UNIPATCH_LIST_GENPATCHES} ]] && \
		unipatch "${UNIPATCH_LIST_DEFAULT} ${UNIPATCH_LIST_GENPATCHES} ${UNIPATCH_LIST}"

	debug-print "Doing premake"

	# allow ebuilds to massage the source tree after patching but before
	# we run misc `make` functions below
	[[ $(type -t kernel-2_hook_premake) == "function" ]] && kernel-2_hook_premake

	debug-print "Doing unpack_set_extraversion"

	[[ -z ${K_NOSETEXTRAVERSION} ]] && unpack_set_extraversion
	unpack_fix_install_path

	# Setup xmakeopts and cd into sourcetree.
	env_setup_xmakeopts
	cd "${S}"

	# We dont need a version.h for anything other than headers
	# at least, I should hope we dont. If this causes problems
	# take out the if/fi block and inform me please.
	# unpack_2_6 should now be 2.6.17 safe anyways
	if [[ ${ETYPE} == headers ]]; then
		kernel_is 2 4 && unpack_2_4
		kernel_is 2 6 && unpack_2_6
	fi
}

kernel-2_src_compile() {
	cd "${S}"
	[[ ${ETYPE} == headers ]] && compile_headers
}

kernel-2_pkg_preinst() {
	[[ ${ETYPE} == headers ]] && preinst_headers
}

kernel-2_src_install() {
	install_universal
	[[ ${ETYPE} == headers ]] && install_headers
	[[ ${ETYPE} == sources ]] && install_sources
}

kernel-2_pkg_postinst() {
	[[ ${ETYPE} == headers ]] && postinst_headers
	[[ ${ETYPE} == sources ]] && postinst_sources
}

kernel-2_pkg_setup() {
	if kernel_is 2 4; then
		if [ "$( gcc-major-version )" -eq "4" ] ; then
			echo
			ewarn "Be warned !! >=sys-devel/gcc-4.0.0 isn't supported with linux-2.4!"
			ewarn "Either switch to another gcc-version (via gcc-config) or use a"
			ewarn "newer kernel that supports gcc-4."
			echo
			ewarn "Also be aware that bugreports about gcc-4 not working"
			ewarn "with linux-2.4 based ebuilds will be closed as INVALID!"
			echo
			epause 10
		fi
	fi

	ABI="${KERNEL_ABI}"
	[[ ${ETYPE} == headers ]] && setup_headers
	[[ ${ETYPE} == sources ]] && echo ">>> Preparing to unpack ..."
}
