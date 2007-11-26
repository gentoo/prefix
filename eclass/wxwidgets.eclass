# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/wxwidgets.eclass,v 1.23 2007/11/25 14:19:39 swegener Exp $

# @ECLASS:			wxwidgets.eclass
# @MAINTAINER:
#  dirtyepic@gentoo.org
#  wxwindows@gentoo.org
# @BLURB:			Manages build configuration for wxGTK-using packages.
# @DESCRIPTION:
#  The wxGTK libraries come in several different possible configurations
#  (release/debug, ansi/unicode, etc.), most of which can be installed
#  side-by-side.  The purpose of this eclass is to give ebuilds the ability to
#  specify what particular flavour they require to build against without
#  interfering with the user-set system configuration.
#
#  Ebuilds that use wxGTK must inherit this eclass.  Otherwise the system
#  default will be used, which would be anything the user set it to.
#
#  Ebuilds are also required to set the global variable WX_GTK_VER, containing
#  the wxGTK SLOT the ebuild requires.  Note that in order for this to work,
#  WX_GTK_VER needs to be set before inheriting the eclass.
#
#  Simple Usage:
#
#   WX_GTK_VER="2.6"
#   inherit wxwidgets
#   DEPEND="=x11-libs/wxGTK-2.6*"
#   RDEPEND="=x11-libs/wxGTK-2.6*"
#
#  That's it.  The eclass will select a sane default configuration to use.  In
#  wxGTK-2.6 the default is ansi.  In wxGTK-2.8 and later it's unicode.  These
#  are the defaults because they are always guaranteed to exist.
#
#  You'll often find yourself in need of a bit more control.  For that see the
#  need-wxwidgets function below.

inherit eutils multilib

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
				[[ -f /usr/$(get_libdir)/wx/config/${wxconf} ]] || continue
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


# @FUNCTION:		need-wxwidgets
# @USAGE:			<configuration>
# @DESCRIPTION:
#  need-wxwidgets is called with one argument, the wxGTK configuration to use.
#
#  Available configurations are:
#
#		ansi
#		unicode
#		base-ansi
#		base-unicode
#
#  Note that in >=wxGTK-2.8, only the unicode versions are available.  The
#  eclass will automatically map ansi to unicode if WX_GTK_VER is set to 2.8 or
#  later.
#
#  There is one deprecated configuration, gtk2, that is equivalent to ansi.
#  It is around for historical reasons and shouldn't be used by new ebuilds.
#
#  This function will set the variable WX_CONFIG to the path of the wx-config
#  script to use.  In most cases you shouldn't have to use it since the
#  /usr/bin/wx-config wrapper points to ${WX_CONFIG} when called from portage.

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

	# base can be provided by both gtk2 and base installations
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

	# This is exported as some configure scripts will check for its presence in
	# the environment.
	export WX_CONFIG="/usr/$(get_libdir)/wx/config/${wxconf}"

	debug-print "WX_CONFIG is ${WX_CONFIG}"

	# TODO: Used by the wx-config wrapper
	export WX_ECLASS_CONFIG="${WX_CONFIG}"

	echo
	einfo "Requested wxWidgets:        ${1} ${WX_GTK_VER}"
	einfo "Using wxWidgets:            ${wxconf}"
	echo
}


# @FUNCTION:		check_wxuse
# @USAGE:			<USE flag>
# @DESCRIPTION:
#  Provides a consistant way to check if wxGTK was built with a particular USE
#  flag enabled.

check_wxuse() {
	debug-print-function $FUNCNAME $*

	[[ -n ${WX_GTK_VER} ]] \
		|| _wxerror "WX_GTK_VER must be set before calling"


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
