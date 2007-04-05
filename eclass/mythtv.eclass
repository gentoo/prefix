# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv.eclass,v 1.6 2007/03/19 07:06:29 cardoe Exp $
#
# Author: Doug Goldstein <cardoe@gentoo.org>
#
# Downloads the MythTV source packages and any patches from the fixes branch
#
inherit eutils

# Release version
MY_PV="${PV%_*}"

# _pre is from SVN trunk while _p is from SVN ${MY_PV}-fixes
if [[ ${MY_PV} != ${PV} ]]; then
	if [[ $PV = *_pre* ]]; then
		SVNREV="${PV##*_pre}"
	elif [[ $PV = *_p* ]]; then
		PATCHREV="${PV##*_p}"
	fi
fi

if [[ ${PN} = mythtv ]]; then
	MY_PN="mythtv"
elif [[ ${PN} = mythtv-themes ]]; then
	MY_PN="myththemes"
else
	MY_PN="mythplugins"
fi

ESVN_REPO_URI="http://svn.mythtv.org/svn/trunk/${MY_PN}"
ESVN_OPTIONS="-r ${SVNREV}"

HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI=""
if [[ -z ${SVNREV} ]] ; then
	SRC_URI="${SRC_URI} mirror://gentoo/${MY_PN}-${MY_PV}.tar.bz2"
fi
if [[ -n ${PATCHREV} ]] ; then
	SRC_URI="${SRC_URI}
		http://dev.gentoo.org/~cardoe/files/mythtv/${MY_PN}-${MY_PV}_svn${PATCHREV}.patch.bz2"
fi

mythtv-fixes_patch() {
	if [[ -n ${PATCHREV} ]]; then
		epatch ${WORKDIR}/${MY_PN}-${MY_PV}_svn${PATCHREV}.patch
	fi
}
