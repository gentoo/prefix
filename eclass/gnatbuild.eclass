# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnatbuild.eclass,v 1.18 2006/09/08 13:28:17 george Exp $
#
# Author: George Shapovalov <george@gentoo.org>
# Belongs to: ada herd <ada@gentoo.org>
#
# Note: HOMEPAGE and LICENSE are set in appropriate ebuild, as 
# gnat is developed by FSF and AdaCore "in parallel"

inherit eutils versionator toolchain-funcs flag-o-matic multilib libtool fixheadtails gnuconfig

EXPORT_FUNCTIONS pkg_setup pkg_postinst pkg_prerm src_unpack src_compile src_install

DESCRIPTION="Based on the ${ECLASS} eclass"

IUSE="nls"
# multilib is supported via profiles now, multilib usevar is deprecated

DEPEND="!dev-lang/gnat"
RDEPEND="app-admin/eselect-gnat"

#PROVIDE="virtual/gnat"

#---->> globals and SLOT <<----

# just a check, this location seems to vary too much, easier to track it in
# ebuild
#[ -z "${GNATSOURCE}" ] && die "please set GNATSOURCE in ebuild! (before inherit)"

# versioning
# because of gnatpro/gnatgpl we need to track both gcc and gnat versions

# these simply default to $PV
GNATMAJOR=$(get_version_component_range 1)
GNATMINOR=$(get_version_component_range 2)
GNATBRANCH=$(get_version_component_range 1-2)
GNATRELEASE=$(get_version_component_range 1-3)
# this one is for the gnat-gpl which is versioned by gcc backend and ACT version
# number added on top
ACT_Ver=$(get_version_component_range 4)

# GCCVER and SLOT logic
#
# I better define vars for package names, as there was discussion on proper
# naming and it may change
PN_GnatGCC="gnat-gcc"
PN_GnatGpl="gnat-gpl"
PN_GnatPro="gnat-pro"

# ATTN! GCCVER stands for the provided backend gcc, not the one on the system
# so tc-* functions are of no use here
#
# GCCVER can be set in the ebuild, but then care will have to be taken
# to set it before inheriting, which is easy to forget
# so set it here for what we can..
if  [[ ${PN} == "${PN_GnatGCC}" ]] || \
	[[ ${PN} == "${PN_GnatGpl}" ]] || \
	[[ ${PN} == "asis" ]]; 
then
	GCCVER="${GNATRELEASE}"
elif [[ ${PN} == "${PN_GnatPro}" ]] ; then
# Ada Core provided stuff is really conservative and changes backends rarely
	case "${GNATMAJOR}" in
		"3")    GCCVER="2.8.1" ;;
		"2005") GCCVER="3.4.5" ;;
	esac
else
	# gpc, gdc and possibly others will use a lot of common logic, I'll try to
	# provide some support for them via this eclass
	die "no support for other gcc frontends so far. Sorry."
fi

# finally extract GCC version strings
GCCMAJOR=$(get_version_component_range 1 "${GCCVER}")
GCCMINOR=$(get_version_component_range 2 "${GCCVER}")
GCCBRANCH=$(get_version_component_range 1-2 "${GCCVER}")
GCCRELEASE=$(get_version_component_range 1-3 "${GCCVER}")

# SLOT logic, make it represent gcc backend, as this is what matters most
SLOT="${GCCBRANCH}"

# possible future crosscompilation support
export CTARGET=${CTARGET:-${CHOST}}

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

# Bootstrap CTARGET and SLOT logic. For now BOOT_TARGET=CHOST is "guaranteed" by
# profiles, so mostly watch out for the right SLOT used in the bootstrap.
BOOT_TARGET=${CTARGET}
BOOT_SLOT=${SLOT}
# optional packages
if [[ ${PN} == "${PN_GnatGpl}" ]] ; then
	ASIS_SRC="${WORKDIR}/asis-${ACT_Ver}-src"
else
	ASIS_SRC="none"
fi

# set our install locations
PREFIX=${GNATBUILD_PREFIX:-${EPREFIX}/usr} # not sure we need this hook, but may be..
LIBPATH=${PREFIX}/lib/${PN}/${CTARGET}/${SLOT}
LIBEXECPATH=${PREFIX}/libexec/${PN}/${CTARGET}/${SLOT}
INCLUDEPATH=${LIBPATH}/include
BINPATH=${PREFIX}/${CTARGET}/${PN}-bin/${SLOT}
DATAPATH=${PREFIX}/share/${PN}-data/${CTARGET}/${SLOT}

# ebuild globals
if [[ ${PN} == "${PN_GnatPro}" ]] && [[ ${GNATMAJOR} == "3" ]]; then
		DEPEND="x86? ( >=app-shells/tcsh-6.0 )"
fi
S="${WORKDIR}/gcc-${GCCVER}"

# bootstrap globals, common to src_unpack and src_compile
GNATBOOT="${WORKDIR}/usr"
GNATBUILD="${WORKDIR}/build"

# necessary for detecting lib locations and creating env.d entry
#XGCC="${GNATBUILD}/gcc/xgcc -B${GNATBUILD}/gcc"

#----<< globals and SLOT >>----

# set SRC_URI's in ebuilds for now

#----<< support checks >>----
# skipping this section - do not care about hardened/multilib for now

#---->> specs + env.d logic <<----
# TODO!!!
# set MANPATH, etc..
#----<< specs + env.d logic >>----


#---->> some helper functions <<----
is_multilib() {
	[[ ${GCCMAJOR} < 3 ]] && return 1
	case ${CTARGET} in
		mips64*|powerpc64*|s390x*|sparc64*|x86_64*)
			has_multilib_profile || use multilib ;;
		*)  false ;;
	esac
}

# adapted from toolchain,
# left only basic multilib functionality and cut off mips stuff

create_specs_file() {
	einfo "Creating a vanilla gcc specs file"
	"${WORKDIR}"/build/gcc/xgcc -dumpspecs > "${WORKDIR}"/build/vanilla.specs
}


create_gnat_env_entry() {
	dodir /etc/env.d/gnat
	local gnat_envd_base="/etc/env.d/gnat/${CTARGET}-${PN}-${SLOT}"

	gnat_envd_file="${D}${gnat_envd_base}"
#	gnat_specs_file=""

	echo "PATH=\"${BINPATH}:${LIBEXECPATH}\"" > ${gnat_envd_file}
	echo "ROOTPATH=\"${BINPATH}:${LIBEXECPATH}\"" >> ${gnat_envd_file}

	LDPATH="${LIBPATH}"
	for path in 32 64 o32 ; do
		[[ -d ${LIBPATH}/${path} ]] && LDPATH="${LDPATH}:${LIBPATH}/${path}"
	done
	echo "LDPATH=\"${LDPATH}\"" >> ${gnat_envd_file}

	echo "MANPATH=\"${DATAPATH}/man\"" >> ${gnat_envd_file}
	echo "INFOPATH=\"${DATAPATH}/info\"" >> ${gnat_envd_file}

	is_crosscompile && echo "CTARGET=${CTARGET}" >> ${gnat_envd_file}

	# Set which specs file to use
#	[[ -n ${gnat_specs_file} ]] && echo "GCC_SPECS=\"${gnat_specs_file}\"" >> ${gnat_envd_file}
}

# eselect stuff taken straight from toolchain.eclass and greatly simplified
add_profile_eselect_conf() {
	local gnat_config_file=$1
	local abi=$2
	local var

	echo >> ${gnat_config_file}
	if ! is_multilib ; then
		echo "  ctarget=${CTARGET}" >> ${gnat_config_file}
	else
		echo "[${abi}]" >> ${gnat_config_file}
		var="CTARGET_${abi}"
		if [[ -n ${!var} ]] ; then
			echo "  ctarget=${!var}" >> ${gnat_config_file}
		else
			var="CHOST_${abi}"
			if [[ -n ${!var} ]] ; then
				echo "  ctarget=${!var}" >> ${gnat_config_file}
			else
				echo "  ctarget=${CTARGET}" >> ${gnat_config_file}
			fi
		fi
	fi

	var="CFLAGS_${abi}"
	if [[ -n ${!var} ]] ; then
		echo "  cflags=${!var}" >> ${gnat_config_file}
	fi
}


create_eselect_conf() {
	# it would be good to source gnat.eselect module here too,
	# but we only need one path
	local config_dir="/usr/share/gnat/eselect"
	local gnat_config_file="${D}/${config_dir}/${CTARGET}-${PN}-${SLOT}"
	local abi

	dodir ${config_dir}

	echo "[global]" > ${gnat_config_file}
	echo "  version=${CTARGET}-${SLOT}" >> ${gnat_config_file}
	echo "  binpath=${BINPATH}" >> ${gnat_config_file}
	echo "  libexecpath=${LIBEXECPATH}" >> ${gnat_config_file}
	echo "  ldpath=${LIBPATH}" >> ${gnat_config_file}
	echo "  manpath=${DATAPATH}/man" >> ${gnat_config_file}
	echo "  infopath=${DATAPATH}/info" >> ${gnat_config_file}
#     echo "  alias_cc=gcc" >> ${compiler_config_file}
#     echo "  stdcxx_incdir=${STDCXX_INCDIR##*/}" >> ${compiler_config_file}
	echo "  bin_prefix=${CTARGET}" >> ${gnat_config_file}

	for abi in $(get_all_abis) ; do
		add_profile_eselect_conf "${gnat_config_file}" "${abi}"
	done
}



should_we_eselect_gnat() {
	# we only want to switch compilers if installing to / or /tmp/stage1root
	[[ ${ROOT} == "/" ]] || return 1

	# if the current config is invalid, we definitely want a new one
	# Note: due to bash quirkiness, the following must not be 1 line
	local curr_config 
	curr_config=$(eselect --no-color gnat show | grep ${CTARGET} | awk '{ print $1 }') || return 0
	[[ -z ${curr_config} ]] && return 0

	# extraction of profile prats and all the relevant logic of toolchain.eclass
	# is contained  here in SLOT and PN vars. The answer basically is, whether
	# we have the same profile. A new one should not be enacted

	if [[ ${curr_config} == ${CTARGET}-${PN}-${SLOT} ]] ; then
		return 0
	else
		einfo "The current gcc config appears valid, so it will not be"
		einfo "automatically switched for you.  If you would like to"
		einfo "switch to the newly installed gcc version, do the"
		einfo "following:"
		echo
		einfo "eselect compiler set <profile>"
		echo
		ebeep
		return 1
	fi
}

# active compiler selection, called from pkg_postinst
do_gnat_config() {
	eselect gnat set ${CTARGET}-${PN}-${SLOT} &> /dev/null

	einfo "The following gnat profile has been activated:"
	einfo "${CTARGET}-${PN}-${SLOT}"
	einfo ""
	einfo "The compiler has been installed as gnatgcc, and the coverage testing"
	einfo "tool as gnatgcov."
}


# Taken straight from the toolchain.eclass. Only removed the "obsolete hunk"
#
# The purpose of this DISGUSTING gcc multilib hack is to allow 64bit libs
# to live in lib instead of lib64 where they belong, with 32bit libraries
# in lib32. This hack has been around since the beginning of the amd64 port,
# and we're only now starting to fix everything that's broken. Eventually
# this should go away.
#
# Travis Tilley <lv@gentoo.org> (03 Sep 2004)
#
disgusting_gcc_multilib_HACK() {
	local config
	local libdirs
	case $(tc-arch) in
		amd64)
			config="i386/t-linux64"
			libdirs="../$(get_abi_LIBDIR amd64) ../$(get_abi_LIBDIR x86)" \
		;;
		ppc64)
			config="rs6000/t-linux64"
			libdirs="../$(get_abi_LIBDIR ppc64) ../$(get_abi_LIBDIR ppc)" \
		;;
	esac

	einfo "updating multilib directories to be: ${libdirs}"
	sed -i -e "s:^MULTILIB_OSDIRNAMES.*:MULTILIB_OSDIRNAMES = ${libdirs}:" ${S}/gcc/config/${config}
}


#---->> pkg_* <<----
gnatbuild_pkg_setup() {
	debug-print-function ${FUNCNAME} $@

	# Setup variables which would normally be in the profile
	if is_crosscompile ; then
		multilib_env ${CTARGET}
	fi

	# we dont want to use the installed compiler's specs to build gnat!
	unset GCC_SPECS
}

gnatbuild_pkg_postinst() {
	if should_we_eselect_gnat; then
		do_gnat_config
	fi
}

# eselect-gnat can be unmerged together with gnat-*, so we better do this before
# actual removal takes place, rather than in postrm, like toolchain does
gnatbuild_pkg_prerm() {
	# files for eselect module are left behind, so we need to cleanup.
	if [ ! -f ${EPREFIX}/usr/share/eselect/modules/gnat.eselect ] ; then
		eerror "eselect-gnat was prematurely unmerged!"
		eerror "You will have to manually remove unnecessary files"
		eerror "under /etc/eselect/gnat and /etc/env.d/55gnat-xxx"
		exit # should *not* die, as this will stop unmerge!
	fi

	# this copying/modifying and then sourcing of a gnat.eselect is a hack,
	# but having a duplicate functionality is really bad - gnat.eselect module
	# might change..
	cat ${EPREFIX}/usr/share/eselect/modules/gnat.eselect | \
		grep -v "svn_date_to_version" | \
		grep -v "DESCRIPTION" \
		> ${WORKDIR}/gnat.esel
	. ${WORKDIR}/gnat.esel

	# see if we need to unset gnat
	if [[ $(get_current_gnat) == "${CTARGET}-${PN}-${SLOT}" ]] ; then
		eselect gnat unset &> /dev/null
	fi
}
#---->> pkg_* <<----

#---->> src_* <<----

# common unpack stuff
gnatbuild_src_unpack() {
	debug-print-function ${FUNCNAME} $@
	[ -z "$1" ] &&  gnatbuild_src_unpack all

	while [ "$1" ]; do
	case $1 in
		base_unpack)
			unpack ${A}

			cd ${S}
			# patching gcc sources, following the toolchain
			EPATCH_MULTI_MSG="Applying Gentoo patches ..." \
				epatch "${FILESDIR}"/patches/*.patch
			# Replacing obsolete head/tail with POSIX compliant ones
			ht_fix_file */configure

			if ! is_crosscompile && is_multilib && \
				[[ ( $(tc-arch) == "amd64" || $(tc-arch) == "ppc64" ) && -z ${SKIP_MULTILIB_HACK} ]] ; then
					disgusting_gcc_multilib_HACK || die "multilib hack failed"
			fi

			# Fixup libtool to correctly generate .la files with portage
			cd "${S}"
			elibtoolize --portage --shallow --no-uclibc

			gnuconfig_update
			# update configure files
			einfo "Fixing misc issues in configure files"
			for f in $(grep -l 'autoconf version 2.13' $(find "${S}" -name configure)) ; do
				ebegin "  Updating ${f}"
				patch "${f}" "${FILESDIR}"/gcc-configure-LANG.patch >& "${T}"/configure-patch.log \
					|| eerror "Please file a bug about this"
				eend $?
			done
		;;

		common_prep)
			# Prepare the gcc source directory
			if [ "2.8.1" == "${GCCVER}" ] ; then
				cd "${S}"
			else
				cd "${S}/gcc"
			fi
			touch cstamp-h.in
			touch ada/[es]info.h
			touch ada/nmake.ad[bs]
			# set the compiler name to gnatgcc
			for i in `find ada/ -name '*.ad[sb]'`; do \
				sed -i -e "s/\"gcc\"/\"gnatgcc\"/g" ${i}; \
			done
			# add -fPIC flag to shared libs for 3.4* backend
			if [ "3.4" == "${GCCBRANCH}" ] ; then
				cd ada
				epatch ${FILESDIR}/gnat-Make-lang.in.patch
			fi

			mkdir -p "${GNATBUILD}"
		;;

		all)
			gnatbuild_src_unpack base_unpack common_prep
		;;
	esac
	shift
	done
}

# it would be nice to split configure and make steps
# but both need to operate inside specially tuned evironment
# so just do sections for now (as in eclass section of handbook)
# sections are: configure, make-tools, bootstrap,
#  gnatlib_and_tools, gnatlib-shared
gnatbuild_src_compile() {
	debug-print-function ${FUNCNAME} $@
	if [[ -z "$1" ]]; then
		gnatbuild_src_compile all
		return $?
	fi

	if [[ "all" == "$1" ]]
	then # specialcasing "all" to avoid scanning sources unnecessarily
		gnatbuild_src_compile configure make-tools \
			bootstrap gnatlib_and_tools gnatlib-shared

	else
		# Set some paths to our bootstrap compiler.
		export PATH="${GNATBOOT}/bin:${PATH}"
		if [[ "${PN_GnatPro}-3.15p" == "${P}" ]]; then
			GNATLIB="${GNATBOOT}/lib/gcc-lib/${BOOT_TARGET}/${BOOT_SLOT}"
		else
			# !ATTN! the *installed* compilers have ${PN} as part of their
			# LIBPATH, while the *bootstrap* uses hardset "gnatgcc" in theirs
			# (which is referenced as GNATLIB below)
			GNATLIB="${GNATBOOT}/lib/gnatgcc/${BOOT_TARGET}/${BOOT_SLOT}"
		fi

		export CC="${GNATBOOT}/bin/gnatgcc"
		export INCLUDE_DIR="${GNATLIB}/include"
		export LIB_DIR="${GNATLIB}"
		export LDFLAGS="-L${GNATLIB}"

		# additional vars from gnuada and elsewhere
		export LD_RUN_PATH="${LIBPATH}"
		export LIBRARY_PATH="${GNATLIB}"
		export LD_LIBRARY_PATH="${GNATLIB}"
#		export COMPILER_PATH="${GNATBOOT}/bin/"

		export ADA_OBJECTS_PATH="${GNATLIB}/adalib"
		export ADA_INCLUDE_PATH="${GNATLIB}/adainclude"

#		einfo "CC=${CC},
#			ADA_INCLUDE_PATH=${ADA_INCLUDE_PATH},
#			LDFLAGS=${LDFLAGS},
#			PATH=${PATH}"

		while [ "$1" ]; do
		case $1 in
			configure)
				debug-print-section configure
				# Configure gcc
				local confgcc

				# some cross-compile logic from toolchain
				confgcc="${confgcc} --host=${CHOST}"
				if is_crosscompile || tc-is-cross-compiler ; then
					confgcc="${confgcc} --target=${CTARGET}"
				fi
				[[ -n ${CBUILD} ]] && confgcc="${confgcc} --build=${CBUILD}"

				# Native Language Support
				if use nls ; then
					confgcc="${confgcc} --enable-nls --without-included-gettext"
				else
					confgcc="${confgcc} --disable-nls"
				fi

				# reasonably sane globals (from toolchain)
				confgcc="${confgcc} \
					--with-system-zlib \
					--disable-checking \
					--disable-werror \
					--disable-libunwind-exceptions"

#				einfo "confgcc=${confgcc}"

				cd "${GNATBUILD}"
				CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" "${S}"/configure \
					--prefix=${EPREFIX} \
					--bindir=${BINPATH} \
					--includedir=${INCLUDEPATH} \
					--libdir="${LIBPATH}" \
					--libexecdir="${LIBEXECPATH}" \
					--datadir=${DATAPATH} \
					--mandir=${DATAPATH}/man \
					--infodir=${DATAPATH}/info \
					--program-prefix=gnat \
					--enable-languages="c,ada" \
					--enable-libada \
					--with-gcc \
					--enable-threads=posix \
					--enable-shared \
					--with-system-zlib \
					${confgcc} || die "configure failed"
			;;

			make-tools)
				debug-print-section make-tools
				# Compile helper tools
				cd "${GNATBOOT}"
				cp ${S}/gcc/ada/xtreeprs.adb .
				cp ${S}/gcc/ada/xsinfo.adb .
				cp ${S}/gcc/ada/xeinfo.adb .
				cp ${S}/gcc/ada/xnmake.adb .
				gnatmake xtreeprs && \
					gnatmake xsinfo && \
					gnatmake xeinfo && \
					gnatmake xnmake || die "building helper tools"
			;;

			bootstrap)
				debug-print-section bootstrap
				# and, finally, the build itself
				cd "${GNATBUILD}"
				emake bootstrap || die "bootstrap failed"
			;;

			gnatlib_and_tools)
				debug-print-section gnatlib_and_tools
				einfo "building gnatlib_and_tools"
				cd "${GNATBUILD}"
				emake -j1 -C gcc gnatlib_and_tools || \
					die "gnatlib_and_tools failed"
			;;

			gnatlib-shared)
				debug-print-section gnatlib-shared
				einfo "building shared lib"
				cd "${GNATBUILD}"
				rm -f gcc/ada/rts/*.{o,ali} || die
				#otherwise make tries to reuse already compiled (without -fPIC) objs..
				emake -j1 -C gcc gnatlib-shared LIBRARY_VERSION="${GCCBRANCH}" || \
					die "gnatlib-shared failed"
			;;

		esac
		shift
		done # while
	fi   # "all" == "$1"
}


gnatbuild_src_install() {
	debug-print-function ${FUNCNAME} $@

	if [[ -z "$1" ]] ; then
		gnatbuild_src_install all
		return $?
	fi

	while [ "$1" ]; do
	case $1 in
	install) # runs provided make install
		debug-print-section install
		# Do not allow symlinks in /usr/lib/gcc/${CHOST}/${MY_PV}/include as
		# this can break the build.
		for x in "${GNATBUILD}"/gcc/include/* ; do
			if [ -L ${x} ] ; then
				rm -f ${x}
			fi
		done
		# Remove generated headers, as they can cause things to break
		# (ncurses, openssl, etc). (from toolchain.eclass)
		for x in $(find "${WORKDIR}"/build/gcc/include/ -name '*.h') ; do
			grep -q 'It has been auto-edited by fixincludes from' "${x}" \
				&& rm -f "${x}"
		done


		# The install itself. Straight make DESTDIR=${D} install causes access
		# violation (unlink of gprmake). A siple workaround for now.
		cd "${GNATBUILD}"
		make DESTDIR=${D} bindir="${D}${BINPATH}"  install || die
		mv "${D}${D}${PREFIX}/${CTARGET}" "${D}${PREFIX}"
		rm -rf "${D}var"

		#make a convenience info link
		dosym ${DATAPATH}/info/gnat_ugn_unw.info ${DATAPATH}/info/gnat.info
		;;

	move_libs)
		debug-print-section move_libs

		# first we need to remove some stuff to make moving easier
		rm -rf "${D}${LIBPATH}"/{32,include,libiberty.a}
		# gcc insists on installing libs in its own place
		mv "${D}${LIBPATH}/gcc/${CTARGET}/${GCCRELEASE}"/* "${D}${LIBPATH}"
		mv "${D}${LIBEXECPATH}/gcc/${CTARGET}/${GCCRELEASE}"/* "${D}${LIBEXECPATH}"

		# libgcc_s  and, with gcc>=4.0, other libs get installed in multilib specific locations by gcc
		# we pull everything together to simplify working environment
		if has_multilib_profile ; then
			case $(tc-arch) in
				amd64)
					mv "${D}${LIBPATH}"/../$(get_abi_LIBDIR amd64)/* "${D}${LIBPATH}"
					mv "${D}${LIBPATH}"/../$(get_abi_LIBDIR x86)/* "${D}${LIBPATH}"/32
				;;
				ppc64)
					# not supported yet, will have to be adjusted when we
					# actually build gnat for that arch
				;;
			esac
		fi

		# force gnatgcc to use its own specs - versions prior to 4.x read specs
		# from system gcc location. Do the simple wrapper trick for now
		# !ATTN! change this if eselect-gnat starts to follow eselect-compiler
		if [[ ${GCCVER} < 3.4.6 ]] ; then
			# gcc 4.1 uses builtin specs. What about 4.0?
			cd "${D}${BINPATH}"
			mv gnatgcc gnatgcc_2wrap
			cat > gnatgcc << EOF
#! /bin/bash
# wrapper to cause gnatgcc read appropriate specs and search for the right .h
# files (in case no matching gcc is installed)
BINDIR=\$(dirname \$0)
# The paths in the next line have to be absolute, as gnatgcc may be called from
# any location
\${BINDIR}/gnatgcc_2wrap -specs="${LIBPATH}/specs" -I"${LIBPATH}/include" \$@
EOF
			chmod a+x gnatgcc
		fi

		# earlier gnat's generate some Makefile's at generic location, need to
		# move to avoid collisions
		[ -f "${D}${PREFIX}"/share/gnat/Makefile.generic ] &&
			mv "${D}${PREFIX}"/share/gnat/Makefile.* "${D}${DATAPATH}"

		# use gid of 0 because some stupid ports don't have
		# the group 'root' set to gid 0 (toolchain.eclass)
		chown -R root:0 "${D}${LIBPATH}"
		;;

	cleanup)
		debug-print-section cleanup

		rm -rf "${D}${LIBPATH}"/{gcc,install-tools,../lib{32,64}}
		rm -rf "${D}${LIBEXECPATH}"/{gcc,install-tools}

		# this one is installed by gcc and is a duplicate even here anyway
		rm -f "${D}${BINPATH}/${CTARGET}-gcc-${GCCRELEASE}"

		# remove duplicate docs
		cd "${D}${DATAPATH}"
		has noinfo ${FEATURES} \
			&& rm -rf info \
			|| rm -f info/{dir,gcc,cpp}*
		has noman  ${FEATURES} \
			&& rm -rf man \
			|| rm -rf man/man7/
		;;

	prep_env)
		#dodir /etc/env.d/gnat
		#create_gnat_env_entry
		# instead of putting junk under /etc/env.d/gnat we recreate env files as
		# needed with eselect
		create_eselect_conf
		;;

	all)
		gnatbuild_src_install install move_libs cleanup prep_env
		;;
	esac
	shift
	done # while
}
