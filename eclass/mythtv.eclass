# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv.eclass,v 1.15 2009/07/19 04:12:59 cardoe Exp $
#
# @ECLASS: mythtv.eclass
# @AUTHOR: Doug Goldstein <cardoe@gentoo.org>
# @MAINTAINER: Doug Goldstein <cardoe@gentoo.org>
# @BLURB: Downloads the MythTV source packages and any patches from the fixes branch
#

inherit versionator

# Release version
MY_PV="${PV%_*}"

# what product do we want
case "${PN}" in
	       mythtv) MY_PN="mythtv";;
	mythtv-themes) MY_PN="myththemes";;
	mythtv-themes-extra) MY_PN="themes";;
	            *) MY_PN="mythplugins";;
esac

# _pre is from SVN trunk while _p and _beta are from SVN ${MY_PV}-fixes
# TODO: probably ought to do something smart if the regex doesn't match anything
[[ "${PV}" =~ (_beta|_pre|_p|_alpha)([0-9]+) ]] || {
	eerror "Invalid version requested (_alpha|_beta|_pre|_p) only"
	exit 1
}

REV_PREFIX="${BASH_REMATCH[1]}" # _beta, _pre, or _p
MYTHTV_REV="${BASH_REMATCH[2]}" # revision number

case $REV_PREFIX in
	_pre|_alpha) MYTHTV_REPO="trunk/${MY_PN}";;
	_p|_beta) VER_COMP=( $(get_version_components ${MY_PV}) )
	          FIXES_VER="${VER_COMP[0]}-${VER_COMP[1]}"
	          MYTHTV_REPO="branches/release-${FIXES_VER}-fixes/${MY_PN}";;
esac

HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI="http://svn.mythtv.org/trac/changeset/${MYTHTV_REV}/${MYTHTV_REPO}?old_path=%2F&format=zip -> ${MY_PN}-${PV}.zip"
S="${WORKDIR}/${MYTHTV_REPO}"
