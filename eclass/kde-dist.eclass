# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kde-dist.eclass,v 1.76 2009/11/01 08:23:56 abcd Exp $

# @DEAD
# This eclass was only used for the old monolithic ebuilds; just enough
# functionality remains to install 3.5.9 or remove old versions

inherit kde

need-kde ${PV}

DESCRIPTION="KDE ${PV} - "
HOMEPAGE="http://www.kde.org/"
SRC_URI="mirror://kde/stable/${PV}/src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="${KDEMAJORVER}.${KDEMINORVER}"

# add blockers on split packages derived from this one
for x in $(get-child-packages ${CATEGORY}/${PN}); do
	case ${EAPI:-0} in
		# Add EAPIs without SLOT dependencies.
		0)  DEPEND="${DEPEND} !=${x}-${KDEMAJORVER}.${KDEMINORVER}*"
			RDEPEND="${RDEPEND} !=${x}-${KDEMAJORVER}.${KDEMINORVER}*"
			;;
		# EAPIs with SLOT dependencies.
		*)  DEPEND="${DEPEND} !${x}:${SLOT}"
			RDEPEND="${RDEPEND} !${x}:${SLOT}"
			;;
	esac
done
