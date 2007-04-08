# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/rotix/rotix-0.83.ebuild,v 1.12 2007/03/21 21:51:45 armin76 Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Rotix allows you to generate rotational obfuscations."
HOMEPAGE="http://elektron.its.tudelft.nl/~hemmin98/rotix.html"
SRC_URI="http://elektron.its.tudelft.nl/~hemmin98/rotix_releases/${P}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="nls"

RDEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PV}-respect-CFLAGS-and-dont-strip.patch
}

src_compile() {
	local myconf
	use nls && myconf="--i18n=1"
	use elibc_glibc || use nls && append-flags -lintl
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR=${D} install || die
}
