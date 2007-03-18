# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/rotix/rotix-0.83.ebuild,v 1.11 2005/01/01 12:38:14 eradicator Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Rotix allows you to generate rotational obfuscations."
HOMEPAGE="http://elektron.its.tudelft.nl/~hemmin98/rotix.html"
SRC_URI="http://elektron.its.tudelft.nl/~hemmin98/rotix_releases/${P}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="nls"

RDEPEND="nls? ( sys-devel/gettext )"

src_compile() {
	local myconf
	use nls && myconf="--i18n=1"
	[[ ${CHOST} == *-darwin* ]] && use nls && append-flags -lintl
	econf ${myconf} || die
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
}
