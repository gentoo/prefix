# Copyright 1999-2006 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnustep.eclass,v 1.35 2006/09/03 18:08:45 grobian Exp $

inherit gnustep-funcs eutils flag-o-matic

DESCRIPTION="EClass designed to facilitate building GNUstep Apps, Frameworks, and Bundles on Gentoo."

###########################################################################
# IUSE variables across all GNUstep packages
# ##### All GNUstep applications / libs get these
# "debug"	- enable code for debugging; also nostrip
# "profile"	- enable code for profiling; also nostrip
# "doc" - build and install documentation, if available
IUSE="debug profile doc"
if use debug || use profile; then
	RESTRICT="nostrip"
fi
###########################################################################

###########################################################################
# Internal variables
#__GS_INSTALL_DOMAIN="GNUSTEP_SYSTEM_ROOT"
#__GS_USER_ROOT_SUFFIX="/"
#__GS_MAKE_EVAL=""
#__GS_PREFIX="/usr/GNUstep"
#__GS_SYSTEM_ROOT="/usr/GNUstep/System"
#__GS_LOCAL_ROOT="/usr/GNUstep/Local"
#__GS_NETWORK_ROOT="/usr/GNUstep/Network"
#__GS_USER_ROOT="~/GNUstep"
###########################################################################

###########################################################################
# Variables
# ---------
# ~ legend
# (a) - append more data if needed
# (n) - do not override without a good reason
# (y) - override as appropriate per ebuild
# Build general GNUstep ebuild depends here
# - most .app should be set up this way:
#   + (a) DEPEND="${GS_DEPEND} other/depend ..."
#   + (a) RDEPEND="${GS_RDEPEND} other/rdepend ..."
# - core libraries and other packages that need to
#     specialize more can use:
#   + (n) DOC_DEPEND - packages needed to build docs
#   + (n) GNUSTEP_CORE_DEPEND - packages needed to build any gnustep package
#   + (n) GNUSTEP_BASE_DEPEND - packages needed to build gnustep CLI only apps
#   + (n) GNUSTEP_GUI_DEPEND - packages needed to build gnustep GUI apps
#   + (n) DEBUG_DEPEND - packages needed to utilize .debug apps
#   + (n) DOC_RDEPEND - packages needed to view docs
###########################################################################
DOC_DEPEND="doc? ( virtual/tetex
	=dev-tex/latex2html-2002*
	>=app-text/texi2html-1.64 )"
GNUSTEP_CORE_DEPEND="|| ( >=sys-devel/gcc-3.3.5 sys-devel/gcc-apple )
	${DOC_DEPEND}"
##########################################
# Armando Di Cianno <fafhrd@gentoo.org>
# 20050414 - Removing use of the next two entries from all dependent ebuilds;
# they were doing bad things to dependencies
GNUSTEP_BASE_DEPEND="${GNUSTEP_CORE_DEPEND}
	gnustep-base/gnustep-make
	gnustep-base/gnustep-base"
GNUSTEP_GUI_DEPEND="${GNUSTEP_BASE_DEPEND}
	gnustep-base/gnustep-gui"
##########################################
GS_DEPEND="gnustep-base/gnustep-env"
DEBUG_DEPEND="debug? ( >=sys-devel/gdb-6.0 )"
DOC_RDEPEND="doc? ( virtual/man
	>=sys-apps/texinfo-4.6 )"
GS_RDEPEND="${GS_DEPEND}
	${DEBUG_DEPEND}
	${DOC_RDEPEND}"
###########################################################################

###########################################################################
# Ebuild function overrides
# -------------------------
gnustep_pkg_setup() {
	if test_version_info 3.3
	then
		#einfo "Using gcc 3.3*"
		# gcc 3.3 doesn't support certain 3.4.1 options,
		#  as well as having less specific -march options
		replace-flags -march=pentium-m -march=pentium3
		filter-flags -march=k8
		filter-flags -march=athlon64
		filter-flags -march=opteron

		strip-unsupported-flags
	elif test_version_info 3.4
	then
		# strict-aliasing is known to break obj-c stuff in gcc-3.4*
		filter-flags -fstrict-aliasing
	fi

	# known to break ObjC (bug 86089)
	filter-flags -fomit-frame-pointer
}

gnustep_src_compile() {
	egnustep_env
	egnustep_make || die
}

gnustep_src_install() {
	egnustep_env
	egnustep_install || die
	if use doc ; then
		egnustep_env
		egnustep_doc || die
	fi
	egnustep_package_config
}

gnustep_pkg_postinst() {
	egnustep_package_config_info
}
###########################################################################

EXPORT_FUNCTIONS pkg_setup src_compile src_install pkg_postinst
