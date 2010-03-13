# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/rotix/rotix-0.83.ebuild,v 1.14 2010/02/22 18:37:02 phajdan.jr Exp $

inherit eutils flag-o-matic

DESCRIPTION="Rotix allows you to generate rotational obfuscations."
HOMEPAGE="http://elektron.its.tudelft.nl/~hemmin98/rotix.html"
SRC_URI="http://elektron.its.tudelft.nl/~hemmin98/rotix_releases/${P}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-devel/gettext"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-respect-CFLAGS-and-dont-strip.patch
	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	use elibc_glibc || append-flags -lintl
	econf --i18n=1 || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
