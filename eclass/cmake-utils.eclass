# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/cmake-utils.eclass,v 1.8 2008/04/23 11:55:51 ingmar Exp $

# @ECLASS: cmake-utils.eclass
# @MAINTAINER:
# kde@gentoo.org
# @BLURB: common ebuild functions for cmake-based packages
# @DESCRIPTION:
# The cmake-utils eclass contains functions that make creating ebuilds for
# cmake-based packages much easier.
# Its main features are support of out-of-source builds as well as in-source
# builds and an implementation of the well-known use_enable and use_with
# functions for CMake.

# Original author: Zephyrus (zephyrus@mirach.it)

inherit toolchain-funcs multilib

DESCRIPTION="Based on the ${ECLASS} eclass"

DEPEND=">=dev-util/cmake-2.4.6"

EXPORT_FUNCTIONS src_compile src_test src_install

# Internal function use by cmake-utils_use_with and cmake-utils_use_enable
_use_me_now() {
	debug-print-function $FUNCNAME $*
	[[ -z $2 ]] && die "cmake-utils_use-$1 <USE flag> [<flag name>]"
	echo "-D$1_${3:-$2}=$(use $2 && echo ON || echo OFF)"
}

# @VARIABLE: DOCS
# @DESCRIPTION:
# Documents to dodoc

# @FUNCTION: cmake-utils_use_with
# @USAGE: <USE flag> [flag name]
# @DESCRIPTION:
# Based on use_with. See ebuild(5).
#
# `cmake-utils_use_with foo FOO` echoes -DWITH_FOO=ON if foo is enabled
# and -DWITH_FOO=OFF if it is disabled.
cmake-utils_use_with() { _use_me_now WITH "$@" ; }

# @FUNCTION: cmake-utils_use_enable
# @USAGE: <USE flag> [flag name]
# @DESCRIPTION:
# Based on use_enable. See ebuild(5).
#
# `cmake-utils_use_enable foo FOO` echoes -DENABLE_FOO=ON if foo is enabled
# and -DENABLE_FOO=OFF if it is disabled.
cmake-utils_use_enable() { _use_me_now ENABLE "$@" ; }

# @FUNCTION: cmake-utils_use_want
# @USAGE: <USE flag> [flag name]
# @DESCRIPTION:
# Based on use_enable. See ebuild(5).
#
# `cmake-utils_use_want foo FOO` echoes -DWANT_FOO=ON if foo is enabled
# and -DWANT_FOO=OFF if it is disabled.
cmake-utils_use_want() { _use_me_now WANT "$@" ; }

# @FUNCTION: cmake-utils_has
# @USAGE: <USE flag> [flag name]
# @DESCRIPTION:
# Based on use_enable. See ebuild(5).
#
# `cmake-utils_has foo FOO` echoes -DHAVE_FOO=ON if foo is enabled
# and -DHAVE_FOO=OFF if it is disabled.
cmake-utils_has() { _use_me_now HAVE "$@" ; }

# @FUNCTION: cmake-utils_src_compile
# @DESCRIPTION:
# General function for compiling with cmake. Default behaviour is to start an
# out-of-source build. All arguments are passed to cmake-utils_src_make.
cmake-utils_src_compile() {
	debug-print-function $FUNCNAME $*

	if [[ -n "${CMAKE_IN_SOURCE_BUILD}" ]]; then
		cmake-utils_src_configurein
	else
		cmake-utils_src_configureout
	fi
	cmake-utils_src_make "$@"
}

# @FUNCTION: cmake-utils_src_configurein
# @DESCRIPTION:
# Function for software that requires configure and building in the source
# directory.
cmake-utils_src_configurein() {
	debug-print-function $FUNCNAME $*

	local cmakeargs="$(_common_configure_code) ${mycmakeargs} ${EXTRA_ECONF}"

	debug-print "$LINENO $ECLASS $FUNCNAME: mycmakeargs is $cmakeargs"
	cmake ${cmakeargs} . || die "Cmake failed"
}

# @FUNCTION: cmake-utils_src_configureout
# @DESCRIPTION:
# Function for software that requires configure and building outside the source
# tree - default.
cmake-utils_src_configureout() {
	debug-print-function $FUNCNAME $*

	local cmakeargs="$(_common_configure_code) ${mycmakeargs} ${EXTRA_ECONF}"
	mkdir -p "${WORKDIR}"/${PN}_build
	pushd "${WORKDIR}"/${PN}_build > /dev/null

	debug-print "$LINENO $ECLASS $FUNCNAME: mycmakeargs is $cmakeargs"
	cmake ${cmakeargs} "${S}" || die "Cmake failed"

	popd > /dev/null
}

# Internal use only. Common configuration options for all types of builds.
_common_configure_code() {
	local tmp_libdir=$(get_libdir)
	if has debug ${IUSE//+} && use debug; then
		echo -DCMAKE_BUILD_TYPE=Debug
	else
		echo -DCMAKE_BUILD_TYPE=Release
	fi
	echo -DCMAKE_C_COMPILER=$(type -P $(tc-getCC))
	echo -DCMAKE_CXX_COMPILER=$(type -P $(tc-getCXX))
	echo -DCMAKE_INSTALL_PREFIX=${PREFIX:-/usr}
	echo -DLIB_SUFFIX=${tmp_libdir/lib}
	echo -DLIB_INSTALL_DIR=${PREFIX:-/usr}/${tmp_libdir}
	[[ -n ${CMAKE_NO_COLOR} ]] && echo -DCMAKE_COLOR_MAKEFILE=OFF
}

# @FUNCTION: cmake-utils_src_make
# @DESCRIPTION:
# Function for building the package. Automatically detects the build type.
# All arguments are passed to emake:
# "cmake-utils_src_make -j1" can be used to work around parallel make issues.
cmake-utils_src_make() {
	debug-print-function $FUNCNAME $*

	# At this point we can automatically check if it's an out-of-source or an
	# in-source build
	if [[ -d ${WORKDIR}/${PN}_build ]]; then
		pushd "${WORKDIR}"/${PN}_build > /dev/null
	fi
	if ! [[ -z ${CMAKE_COMPILER_VERBOSE} ]]; then
		emake VERBOSE=1 "$@" || die "Make failed!"
	else
		emake "$@" || die "Make failed!"
	fi
	if [[ -d ${WORKDIR}/${PN}_build ]]; then
		popd > /dev/null
	fi
}

# @FUNCTION: cmake-utils_src_install
# @DESCRIPTION:
# Function for installing the package. Automatically detects the build type.
cmake-utils_src_install() {
	debug-print-function $FUNCNAME $*

	# At this point we can automatically check if it's an out-of-source or an
	# in-source build
	if [[ -d  ${WORKDIR}/${PN}_build ]]; then
		pushd "${WORKDIR}"/${PN}_build > /dev/null
	fi
	emake install DESTDIR="${D}" || die "Make install failed"
	if [[ -d  ${WORKDIR}/${PN}_build ]]; then
		popd > /dev/null
	fi

	# Manual document installation
	[[ -n "${DOCS}" ]] && dodoc ${DOCS}
}

# @FUNCTION: cmake-utils_src_test
# @DESCRIPTION:
# Function for testing the package. Automatically detects the build type.
cmake-utils_src_test() {
	debug-print-function $FUNCNAME $*

	# At this point we can automatically check if it's an out-of-source or an
	# in-source build
	if [[ -d ${WORKDIR}/${PN}_build ]]; then
		pushd "${WORKDIR}"/${PN}_build > /dev/null
	fi
	# Standard implementation of src_test
	if emake -j1 check -n &> /dev/null; then
		einfo ">>> Test phase [check]: ${CATEGORY}/${PF}"
		if ! emake -j1 check; then
			die "Make check failed. See above for details."
		fi
	elif emake -j1 test -n &> /dev/null; then
		einfo ">>> Test phase [test]: ${CATEGORY}/${PF}"
		if ! emake -j1 test; then
			die "Make test failed. See above for details."
		fi
	else
		einfo ">>> Test phase [none]: ${CATEGORY}/${PF}"
	fi
	if [[ -d  ${WORKDIR}/${PN}_build ]]; then
		popd > /dev/null
	fi
}
