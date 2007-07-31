# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/wxwidgets.eclass,v 1.19 2007/07/30 01:34:13 dirtyepic Exp $
#
# Original Author:      Rob Cakebread <pythonhead@gentoo.org>
# Current Maintainers:  wxWidgets team <wxwidgets@gentoo.org>

# This eclass helps you find the correct wx-config script so ebuilds
# can use gtk, gtk2 or gtk2+unicode versions of wxGTK

# FUNCTIONS:
# need-wxwidgets:
#   Arguments:
#     2.4: gtk gtk2 unicode !!! 2.4 is being removed from the tree !!!
#     2.6: gtk2 unicode base base-unicode mac mac-unicode
#
# set-wxconfig
#   Arguments: (wxGTK 2.4) wxgtk, wxgtk2, or wxgtk2u
#   Arguments: (wxGTK 2.6) gtk-ansi gtk2-ansi unicode base-ansi base-unicode mac-ansi mac-unicode
#   Note: Don't call this function directly from ebuilds
#
# check_wxuse
#   Check if wxGTK was built with the specified USE flag.
#   Usage:  check_wxuse <USE flag>
#	Note: for now, requires WX_GTK_VER to be set.

inherit multilib flag-o-matic

need-wxwidgets() {
	debug-print-function $FUNCNAME $*
	#If you want to use wxGTK-2.6* export WX_GTK_VER in your ebuild:
	if [ "${WX_GTK_VER}" = "2.6" ]; then
		case $1 in
			gtk)		set-wxconfig gtk-ansi;;
			gtk2)		set-wxconfig gtk2-ansi;;
			unicode)	set-wxconfig gtk2-unicode;;
			base)		set-wxconfig base-ansi;;
			base-unicode)	set-wxconfig base-unicode;;
			mac)		set-wxconfig mac-ansi;;
			mac-unicode)	set-wxconfig mac-unicode;;
			*)		echo "!!! $FUNCNAME: Error: wxGTK was not comipled with $1."
					echo "!!! Adjust your USE flags or re-emerge wxGTK with version you want."
			exit 1;;
		esac

	else
		WX_GTK_VER="2.4"
		case $1 in
			gtk)		set-wxconfig wxgtk;;
			gtk2)		set-wxconfig wxgtk2;;
			unicode)	set-wxconfig wxgtk2u;;
			*)		echo "!!! $FUNCNAME: Error: wxGTK was not compiled with $1."
					echo "!!! Adjust your USE flags or re-emerge wxGTK with the version you want."
			exit 1;;
		esac
	fi
}

set-wxconfig() {

	debug-print-function $FUNCNAME $*

	if [ "${WX_GTK_VER}" = "2.6" ] ; then
		wxconfig_prefix="/usr/$(get_libdir)/wx/config"
		wxconfig_name="${1}-release-${WX_GTK_VER}"
		wxconfig="${wxconfig_prefix}/${wxconfig_name}"
		wxconfig_debug_name="${1}-debug-${WX_GTK_VER}"
		wxconfig_debug="${wxconfig_prefix}/${wxconfig_debug_name}"
	else
		# Default is 2.4:
		wxconfig_prefix="/usr/bin"
		wxconfig_name="${1}-${WX_GTK_VER}-config"
		wxconfig="${wxconfig_prefix}/${wxconfig_name}"
		wxconfig_debug_name="${1}d-${WX_GTK_VER}-config"
		wxconfig_debug="${wxconfig_prefix}/${wxconfig_debug_name}"
	fi

	if [ -e ${wxconfig} ] ; then
		export WX_CONFIG=${wxconfig}
		export WX_CONFIG_NAME=${wxconfig_name}
		export WXBASE_CONFIG_NAME=${wxconfig_name}
		echo " * Using ${wxconfig}"
	elif [ -e ${wxconfig_debug} ] ; then
		export WX_CONFIG=${wxconfig_debug}
		export WX_CONFIG_NAME=${wxconfig_debug_name}
		export WXBASE_CONFIG_NAME=${wxconfig_debug_name}
		echo " * Using ${wxconfig_debug}"
	else
		echo "!!! $FUNCNAME: Error:  Can't find normal or debug version:"
		echo "!!! $FUNCNAME:         ${wxconfig} not found"
		echo "!!! $FUNCNAME:         ${wxconfig_debug} not found"
		case $1 in
			wxgtk)	 echo "!!! You need to emerge wxGTK with wxgtk1 in your USE";;
			wxgtkd)	 echo "!!! You need to emerge wxGTK with wxgtk1 in your USE";;
			gtk-ansi)  echo "!!! GTK-1 support is not available in wxGTK-2.6."
			           echo "!!! Please search bugzilla for this package and file a new bug if one is not already present.";;
			gtkd-ansi) echo "!!! GTK-1 support is not available in wxGTK-2.6.";;

			wxgtk2)	 echo "!!! You need to emerge wxGTK with gtk in your USE";;
			wxgtk2d) echo "!!! You need to emerge wxGTK with gtk in your USE";;
			gtk2-ansi)  echo "!!! You need to emerge wxGTK with gtk in your USE";;
			gtk2d-ansi) echo "!!! You need to emerge wxGTK with gtk in your USE";;

			wxgtk2u)  echo "!!! You need to emerge wxGTK with unicode in your USE";;
			wxgtk2ud) echo "!!! You need to emerge wxGTK with unicode in your USE";;
			gtk2-unicode)  echo "!!! You need to emerge wxGTK with unicode in your USE";;
			gtk2d-unicode) echo "!!! You need to emerge wxGTK with unicode in your USE";;
		esac
		exit 1
	fi
}

check_wxuse() {
	if [[ -z ${WX_GTK_VER} ]]; then
		echo
		eerror "You need to set WX_GTK_VER before calling ${FUNCNAME}."
		die "Missing WX_GTK_VER."
	fi

	ebegin "Checking wxGTK-${WX_GTK_VER} for ${1} support"
	if $(built_with_use =x11-libs/wxGTK-${WX_GTK_VER}* ${1}); then
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
