# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-fonts/encodings/encodings-1.0.2.ebuild,v 1.1 2006/11/09 15:34:59 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org font encodings"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-apps/mkfontscale"

CONFIGURE_OPTIONS="--with-encodingsdir=${EROOT}/usr/share/fonts/encodings"
