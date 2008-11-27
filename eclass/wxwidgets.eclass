# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/wxwidgets.eclass,v 1.26 2008/11/26 06:49:34 dirtyepic Exp $

# @ECLASS:			wxwidgets.eclass
# @MAINTAINER:
#  wxwindows@gentoo.org
# @BLURB:			Manages build configuration for wxGTK-using packages.
# @DESCRIPTION:
#  The wxGTK libraries come in several different possible configurations
#  (release, debug, ansi, unicode, etc.) most of which can be installed
#  side-by-side.  The purpose of this eclass is to provide ebuilds the ability
#  to build against a specific type of profile without interfering with the
#  user-set system configuration.
#
#  Ebuilds that use wxGTK _must_ inherit this eclass.  Otherwise the system
#  profile will be used, meaning whatever the user happened to set it to
#  through eselect-wxwidgets.
#
#  Ebuilds are also required to set the variable WX_GTK_VER, containing
#  the wxGTK SLOT the ebuild requires.
#
#  Simple Usage:
#
# @CODE
#    WX_GTK_VER="2.8"
#
#    inherit wxwidgets
#
#    DEPEND="=x11-libs/wxGTK-2.8*"       (or x11-libs/wxGTK:2.8 for >=EAPI 1)
#    RDEPEND="${DEPEND}"
#    [...]
# @CODE
#
#  In this case the eclass will use the default configuration, which is the GTK
#  libraries and either the "ansi" (in 2.6) or "unicode" (>=2.8) charsets.
#
#  If you need more control over which profile(s) you need to use, see the
#  need-wxwidgets function below.

inherit eutils multilib

EXPORT_FUNCTIONS pkg_setup

# We do this globally so ebuilds can get sane defaults just by inheriting.  They
# can be overridden with need-wxwidgets later if need be.

if [[ -z ${WX_CONFIG} ]]; then
	if [[ -n ${WX_GTK_VER} ]]; then
		if [[ ${WX_GTK_VER} == 2.6 ]]; then
			wxchar="ansi"
		elif [[ ${WX_GTK_VER} == 2.8 ]]; then
			wxchar="unicode"
		fi

		for wxtoolkit in gtk2 base; do
			for wxdebug in release debug; do
				wxconf="${wxtoolkit}-${wxchar}-${wxdebug}-${WX_GTK_VER}"
				if [[ -f /usr/$(get_libdir)/wx/config/${wxconf} ]]; then
					[[ $wxtoolkit == "base" ]] && WXBASE_DIE=1 # see wxwidgets_pkg_setup
				else
					continue
				fi
				WX_CONFIG="/usr/$(get_libdir)/wx/config/${wxconf}"
				# TODO: needed for the wx-config wrapper
				WX_ECLASS_CONFIG="${WX_CONFIG}"
				break
			done
			[[ -n ${WX_CONFIG} ]] && break
		done
		[[ -n ${WX_CONFIG} ]] && export WX_CONFIG WX_ECLASS_CONFIG
	fi
fi

# @FUNCTION:		wxwidgets_pkg_setup
# @DESCRIPTION:
#
#  99.99% of the time, packages building against wxGTK need the GTK libraries.
#  When using the "Simple Usage" case above (WX_GTK_VER before inherit), we have
#  to take into account that the user may have only installed the base libraries
#  (with USE="-X").  Since we can't die in global scope we instead check for
#  the presence of a base profile and then die here if found.
#
#  If you do need to build against the wxBase libraries, you'll have to use
#  need-wxwidgets to do so.
#
#  Note that with an EAPI 2 ebuild you can just DEPEND on x11-libs/wxGTK:2.8[X]
#  and ignore all this nonsense.

wxwidgets_pkg_setup() {
	[[ -n $WXBASE_DIE ]] && check_wxuse X
}

# @FUNCTION:		need-wxwidgets
# @USAGE:			<configuration>
# @DESCRIPTION:
#
#  need-wxwidgets is called with one argument, the wxGTK configuration to use.
#
#  Available configurations are:
#
#    ansi
#    unicode
#    base-ansi
#    base-unicode
#
#  Note that in >=wxGTK-2.8, only the unicode versions are available.  The
#  eclass will automatically map ansi to unicode for you if WX_GTK_VER is
#  set to 2.8 or later.
#
#  There is one deprecated configuration, "gtk2", which is equivalent to ansi.
#  This is leftover from 2.4 when we had gtk1 and gtk2 builds and shouldn't
#  be used by new ebuilds.
#
#  This function will export the variable WX_CONFIG, containing the absolute
#  path to the wx-config script to use.  In most cases you shouldn't need to
#  use it since the /usr/bin/wx-config wrapper will already point to that
#  location when called from the eclass, but it's here if you do.

need-wxwidgets() {
	debug-print-function $FUNCNAME $*

	local wxtoolkit wxchar wxdebug wxconf

	if [[ -z ${WX_GTK_VER} ]]; then
		echo
		eerror "WX_GTK_VER must be set before calling $FUNCNAME."
		echo
		die "WX_GTK_VER missing"
	fi

	if [[ ${WX_GTK_VER} != 2.6 \
		&& ${WX_GTK_VER} != 2.8 ]]; then
			echo
			eerror "Invalid WX_GTK_VER: ${WX_GTK_VER} - must be set to a valid wxGTK SLOT."
			echo
			die "Invalid WX_GTK_VER"
	fi

	debug-print "WX_GTK_VER is ${WX_GTK_VER}"

	case $1 in
		ansi)
			debug-print-section ansi
			if [[ ${WX_GTK_VER} == 2.6 ]]; then
				wxchar="ansi"
			else
				wxchar="unicode"
			fi
			check_wxuse X
			;;
		unicode)
			debug-print-section unicode
			check_wxuse X
			[[ ${WX_GTK_VER} == 2.6 ]] && check_wxuse unicode
			wxchar="unicode"
			;;
		base)
			debug-print-section base
			if [[ ${WX_GTK_VER} == 2.6 ]]; then
				wxchar="ansi"
			else
				wxchar="unicode"
			fi
			;;
		base-unicode)
			debug-print-section base-unicode
			[[ ${WX_GTK_VER} == 2.6 ]] && check_wxuse unicode
			wxchar="unicode"
			;;
		# backwards compatibility
		gtk2)
			debug-print-section gtk2
			if [[ ${WX_GTK_VER} == 2.6 ]]; then
				wxchar="ansi"
			else
				wxchar="unicode"
			fi
			check_wxuse X
			;;
		*)
			echo
			eerror "Invalid $FUNCNAME argument: $1"
			echo
			die "Invalid argument"
			;;
	esac

	debug-print "wxchar is ${wxchar}"

	# since we're no longer in global scope we call built_with_use instead of
	# all the crazy looping

	# wxBase can be provided by both gtk2 and base installations
	if built_with_use =x11-libs/wxGTK-${WX_GTK_VER}* X; then
		wxtoolkit="gtk2"
	else
		wxtoolkit="base"
	fi

	debug-print "wxtoolkit is ${wxtoolkit}"

	# debug or release?
	if built_with_use =x11-libs/wxGTK-${WX_GTK_VER}* debug; then
		wxdebug="debug"
	else
		wxdebug="release"
	fi

	debug-print "wxdebug is ${wxdebug}"

	# put it all together
	wxconf="${wxtoolkit}-${wxchar}-${wxdebug}-${WX_GTK_VER}"

	debug-print "wxconf is ${wxconf}"

	# if this doesn't work, something is seriously screwed
	if [[ ! -f /usr/$(get_libdir)/wx/config/${wxconf} ]]; then
		echo
		eerror "Failed to find configuration ${wxconf}"
		echo
		die "Missing wx-config"
	fi

	debug-print "Found config ${wxconf} - setting WX_CONFIG"

	export WX_CONFIG="/usr/$(get_libdir)/wx/config/${wxconf}"

	debug-print "WX_CONFIG is ${WX_CONFIG}"

	export WX_ECLASS_CONFIG="${WX_CONFIG}"

	echo
	einfo "Requested wxWidgets:        ${1} ${WX_GTK_VER}"
	einfo "Using wxWidgets:            ${wxconf}"
	echo
}


# @FUNCTION:		check_wxuse
# @USAGE:			<USE flag>
# @DESCRIPTION:
#
#  Provides a consistant way to check if wxGTK was built with a particular USE
#  flag enabled.

check_wxuse() {
	debug-print-function $FUNCNAME $*

	if [[ -z ${WX_GTK_VER} ]]; then
		echo
		eerror "WX_GTK_VER must be set before calling $FUNCNAME."
		echo
		die "WX_GTK_VER missing"
	fi

	ebegin "Checking wxGTK-${WX_GTK_VER} for ${1} support"
	if built_with_use =x11-libs/wxGTK-${WX_GTK_VER}* "${1}"; then
		eend 0
	else
		eend 1
		echo
		eerror "${FUNCNAME} - You have requested functionality that requires ${1} support to"
		eerror "have been built into x11-libs/wxGTK."
		eerror
		eerror "Please re-merge =x11-libs/wxGTK-${WX_GTK_VER}* with the ${1} USE flag enabled."
		die "Missing USE flags."
	fi
}
