# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-fonts/font-misc-misc/font-misc-misc-1.0.0.ebuild,v 1.14 2006/09/03 06:34:19 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular


DESCRIPTION="X.Org miscellaneous fonts"
RESTRICT="mirror"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RDEPEND=""
DEPEND="${RDEPEND}
	x11-apps/bdftopcf
	>=media-fonts/font-util-0.99.2"

CONFIGURE_OPTIONS="--with-mapfiles=${XDIR}/share/fonts/util"
