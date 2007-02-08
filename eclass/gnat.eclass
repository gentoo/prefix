# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnat.eclass,v 1.21 2007/02/05 13:21:57 george Exp $
#
# Author: George Shapovalov <george@gentoo.org>
# Belongs to: ada herd <ada@gentoo.org>
#
# This eclass provides the framework for ada lib installation with the split and
# SLOTted gnat compilers (gnat-xxx, gnatbuild.eclass). Each lib gets built once
# for every installed gnat compiler. Activation of a particular bunary module is
# performed by eselect-gnat, when the active compiler gets switched
#
# The ebuilds should define the lib_compile and lib_install functions that are
# called from the (exported) gnat_src_compile function of eclass. These
# functions should operate similarly to the starndard src_compile and
# src_install. The only difference, that they should use $SL variable instead of
# $S (this is where the working cop of source is held) and $DL instead of $D as
# its installation point.

inherit flag-o-matic eutils

EXPORT_FUNCTIONS pkg_setup pkg_postinst src_unpack src_compile

DESCRIPTION="Common procedures for building Ada libs using split gnat compilers"

# really need to make sure we have eselect with new eclass version
DEPEND=">=app-admin/eselect-gnat-0.8"


# ----------------------------------
# Globals

# Locations
# Gnat profile dependent files go under under ${LibTop}/${Gnat_Profile}/${PN}
# and common files go unde SpecsDir, DataDir
PREFIX=/usr
AdalibSpecsDir=${PREFIX}/include/ada
AdalibDataDir=${PREFIX}/share/ada
AdalibLibTop=${PREFIX}/lib/ada

# build-time locations
# SL is a "localized" S, - location where sources are copied for
# profile-specific build
SL=${WORKDIR}/LocalSource

# DL is a "localized destination", where ARCH/SLOT dependent binaries should be
# installed in lib_install
DL=${WORKDIR}/LocalDest

# location of cleaned-up eselect script, for sourcing
EselectScript=${WORKDIR}/gnat.eselect

# file containing environment formed by gnat-eselect (build-time)
BuildEnv=${WORKDIR}/BuildEnv

# environment for installed lib. Profile-specific stuff should use %DL% as a top
# of their location. This (%DL%) will be substituted with a proper location upon
# install
LibEnv=${WORKDIR}/LibEnv


# env file prepared by gnat.eselect only lists new settings for env vars
# we need to change that to prepend, rather than replace action..
# Takes one argument - the file to expand. This file should contain only
# var=value like lines.. (commenst are Ok)
expand_BuildEnv() {
	local line
	for line in $(cat $1); do
		EnvVar=$(echo ${line}|cut -d"=" -f1)
		if [[ "${EnvVar}" == "PATH" ]] ; then
			echo "export ${line}:\${${EnvVar}}" >> $1.tmp
		else
			echo "export ${line}" >> $1.tmp
		fi
	done
	mv $1.tmp $1
}


# ------------------------------------
# Helpers
#
# may be moved to a seperate eclas, if enough accumulated inthis one and in
# gnatbuild.eclass..

# get_all_profile_components splits gnat profile and returns array of its components:
# x86_64-pc-linux-gnu-gnat-gcc-4.1  -> x86_64-pc-linux-gnu-gnat gcc 4.1
# params:
#  $1 - the string to split
get_all_profile_components() {
	local GnatSLOT=${1##*-}
	local remainder=${1%-*}
	local GnatPkg=${reminder##*-}
	remainder=${1%-*}
	echo "${remainder} ${GnatPkg} ${GnatSLOT}"
}

# similar to above, returns only SLOT component:
# x86_64-pc-linux-gnu-gnat-gcc-4.1  -> 4.1
# params:
#  $1 - the string to extract the slot from
get_gnat_SLOT() {
	echo "${1##*-}"
}

# returns only Pkg component:
# x86_64-pc-linux-gnu-gnat-gcc-4.1  -> gcc
# params:
#  $1 - the string to extract the slot from
get_gnat_Pkg() {
	local items=(get_all_profile_components $1)
	echo ${items[1]}
}

# returns only Arch component:
# x86_64-pc-linux-gnu-gnat-gcc-4.1  -> x86_64-pc-linux-gnu
# params:
#  $1 - the string to extract the slot from
get_gnat_Arch() {
	local items=(get_all_profile_components $1)
	echo ${items[0]}
}



# The purpose of this one is to remove all parts of the env entry specific to a
# given lib. Usefull when some lib wants to act differently upon detecting
# itself installed..
#
# params:
#  $1 - name of env var to process
#  $2 (opt) - name of the lib to filter out (defaults to ${PN})
filter_env_var() {
	local entries=(${!1//:/ })
	local libName=${2:-${PN}}
	local env_str
	for entry in ${entries[@]} ; do
		# this simply checks if $libname is a substring of the $entry, should
		# work fine with all the present libs
		if [[ ${entry/${libName}/} == ${entry} ]] ; then
			env_str="${env_str}:${entry}"
		fi
	done
	echo ${env_str}
}

# A simpler helper, for the libs that need to extract active gnat location
# Returns a first entry for a specified env var. Relies on the (presently true)
# convention that first gnat's entries are listed and then of the other
# installed libs.
#
# params:
#  $1 - name of env var to process
get_gnat_value() {
	local entries=(${!1//:/ })
	echo ${entries[0]}
}


# ------------------------------------
# Functions

# Checks the gnat backend SLOT and filters flags correspondingly
# To be called from scr_compile for each profile, before actual compilation
# Parameters:
#  $1 - gnat profile, e.g. x86_64-pc-linux-gnu-gnat-gcc-3.4
gnat_filter_flags() {
	debug-print-function $FUNCNAME $*

	# We only need to filter so severely if backends < 3.4 is detected, which
	# means basically gnat-3.15
	GnatProfile=$1
	if [ -z ${GnatProfile} ]; then
		# should not get here!
		die "please specify a valid gnat profile for flag stripping!"
	fi

	local GnatSLOT="${GnatProfile//*-/}"
	if [[ ${GnatSLOT} < 3.4 ]] ; then
		filter-mfpmath sse 387

		filter-flags -mmmx -msse -mfpmath -frename-registers \
			-fprefetch-loop-arrays -falign-functions=4 -falign-jumps=4 \
			-falign-loops=4 -msse2 -frerun-loop-opt -maltivec -mabi=altivec \
			-fsigned-char -fno-strict-aliasing -pipe

		export ADACFLAGS=${ADACFLAGS:-${CFLAGS}}
		export ADACFLAGS=${ADACFLAGS//-Os/-O2}
		export ADACFLAGS=${ADACFLAGS//pentium-mmx/i586}
		export ADACFLAGS=${ADACFLAGS//pentium[234]/i686}
		export ADACFLAGS=${ADACFLAGS//k6-[23]/k6}
		export ADACFLAGS=${ADACFLAGS//athlon-tbird/i686}
		export ADACFLAGS=${ADACFLAGS//athlon-4/i686}
		export ADACFLAGS=${ADACFLAGS//athlon-[xm]p/i686}
		# gcc-2.8.1 has no amd64 support, so the following two are safe
		export ADACFLAGS=${ADACFLAGS//athlon64/i686}
		export ADACFLAGS=${ADACFLAGS//athlon/i686}
	else
		export ADACFLAGS=${ADACFLAGS:-${CFLAGS}}
	fi

	export ADAMAKEFLAGS=${ADAMAKEFLAGS:-"-cargs ${ADACFLAGS} -margs"}
	export ADABINDFLAGS=${ADABINDFLAGS:-""}
}

gnat_pkg_setup() {
	debug-print-function $FUNCNAME $*
	export ADAC=${ADAC:-gnatgcc}
	export ADAMAKE=${ADAMAKE:-gnatmake}
	export ADABIND=${ADABIND:-gnatbind}
}


gnat_pkg_postinst() {
	einfo "Updating gnat configuration to pick up ${PN} library..."
	eselect gnat update
	elog "The environment has been set up to make gnat automatically find files"
	elog "for the installed library. In order to immediately activate these"
	elog "settings please run:"
	elog
	elog "env-update"
	elog "source /etc/profile"
	einfo
	einfo "Otherwise the settings will become active next time you login"
}



gnat_src_unpack() {
	debug-print-function $FUNCNAME $*
	unpack ${A}
	cat /usr/share/eselect/modules/gnat.eselect | \
		grep -v svn_date_to_version | \
		grep -v DESCRIPTION >	${EselectScript}
}


# standard lib_compile plug. Adapted from base.eclass
lib_compile() {
	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_compile all

	cd ${SL}

	while [ "$1" ]; do
	case $1 in
		configure)
			debug-print-section configure
			econf || die "died running econf, $FUNCNAME:configure"
		;;
		make)
			debug-print-section make
			emake || die "died running emake, $FUNCNAME:make"
		;;
		all)
			debug-print-section all
			lib_compile configure make
		;;
	esac
	shift
	done
}

# Cycles through installed gnat profiles and calls lib_compile and then
# lib_install in turn.
# Use this function to build/install profile-specific binaries. The code
# building/installing common stuff (docs, etc) can go before/after, as needed,
# so that it is called only once..
#
# lib_compile and lib_install are passed the active gnat profile name - may be used or
# discarded as needed..
gnat_src_compile() {
	debug-print-function $FUNCNAME $*

	# We source the eselect-gnat module and use its functions directly, instead of
	# duplicating code or trying to violate sandbox in some way..
	. ${EselectScript} || die "cannot source eselect-gnat module"

	compilers=( $(find_compilers ) )
	if [[ -n ${compilers[@]} ]] ; then
		local i
		for (( i = 0 ; i < ${#compilers[@]} ; i = i + 1 )) ; do
			debug-print-section "compiling for gnat profile ${compilers[${i}]}"

			# copy sources
			mkdir ${DL}
			cp -dpR ${S} ${SL}

			# setup environment
			# As eselect-gnat also manages the libs, this will ensure the right
			# lib profiles are activated too (in case we depend on some Ada lib)
			do_set ${compilers[${i}]} ${BuildEnv}
			expand_BuildEnv ${BuildEnv}
			. ${BuildEnv}
			# many libs (notably xmlada and gtkada) do not like to see
			# themselves installed. Need to strip them from ADA_*_PATH
			# NOTE: this should not be done in pkg_setup, as we setup
			# environment right above
			export ADA_INCLUDE_PATH=$(filter_env_var ADA_INCLUDE_PATH)
			export ADA_OBJECTS_PATH=$(filter_env_var ADA_OBJECTS_PATH)

			# call compilation callback
			cd ${SL}
			gnat_filter_flags ${compilers[${i}]}
			lib_compile ${compilers[${i}]} || die "failed compiling for ${compilers[${i}]}"

			# call install callback
			lib_install ${compilers[${i}]} || die "failed installing profile-specific part for ${compilers[${i}]}"
			# move installed and cleanup
			mv ${DL} ${DL}-${compilers[${i}]}
			rm -rf ${SL}
		done
	else
		die "please make sure you have at least one gnat compiler installed!"
	fi
}


# This function simply moves gnat-profile-specific stuff into proper locations.
# Use src_install in ebuild to install the rest of the package
gnat_src_install() {
	debug-print-function $FUNCNAME $*

	# prep lib specs directory
	. ${EselectScript} || die "cannot source eselect-gnat module"
	dodir ${SPECSDIR}/${PN}

	compilers=( $(find_compilers ) )
	if [[ -n ${compilers[@]} ]] ; then
		local i
		for (( i = 0 ; i < ${#compilers[@]} ; i = i + 1 )) ; do
			debug-print-section "installing for gnat profile ${compilers[${i}]}"

			local DLlocation=${AdalibLibTop}/${compilers[${i}]}
			dodir ${DLlocation}
			cp -dpR "${DL}-${compilers[${i}]}" "${D}/${DLlocation}/${PN}"
			# create profile-specific specs file
			cp ${LibEnv} ${D}/${SPECSDIR}/${PN}/${compilers[${i}]}
			sed -i -e "s:%DL%:${DLlocation}/${PN}:g" ${D}/${SPECSDIR}/${PN}/${compilers[${i}]}
		done
	else
		die || "please make sure you have at least one gnat compiler installed!"
	fi
}
