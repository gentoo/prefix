# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/uudeview/uudeview-0.5.20-r1.ebuild,v 1.5 2009/11/10 04:19:17 abcd Exp $

inherit eutils autotools
IUSE="tk"

DESCRIPTION="uu, xx, base64, binhex decoder"
HOMEPAGE="http://www.fpx.de/fp/Software/UUDeview/"
SRC_URI="http://www.fpx.de/fp/Software/UUDeview/download/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

RDEPEND="tk? ( dev-lang/tk )"

DEPEND="${RDEPEND}
	sys-devel/autoconf"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-bugfixes.patch"
	epatch "${FILESDIR}/${P}-CVE-2004-2265.patch"
	epatch "${FILESDIR}/${P}-CVE-2008-2266.patch"
	epatch "${FILESDIR}/${P}-man.patch"
	epatch "${FILESDIR}/${P}-rename.patch"

	eautoreconf
}

src_compile() {
	econf \
		$(use_enable tk tcl) \
		$(use_enable tk)
	emake || die "emake failed"
}

src_install() {
	# upstream's Makefiles are just broken
	einstall MANDIR="${ED}/usr/share/man/" || die "Failed to install"
	dodoc HISTORY INSTALL README
}
