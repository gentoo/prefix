# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-apps/luit/luit-1.0.2.ebuild,v 1.1 2006/11/09 15:54:32 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="Locale and ISO 2022 support for Unicode terminals"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

RDEPEND="x11-libs/libX11
	x11-libs/libfontenc"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="--with-localealiasfile=${XDIR}/share/X11/locale/locale.alias"
