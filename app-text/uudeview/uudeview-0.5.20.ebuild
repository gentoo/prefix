# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/uudeview/uudeview-0.5.20.ebuild,v 1.15 2008/01/17 20:21:50 grobian Exp $

EAPI="prefix"

IUSE="tk debug"

DESCRIPTION="uu, xx, base64, binhex decoder"
HOMEPAGE="http://www.fpx.de/fp/Software/UUDeview/"
SRC_URI="http://www.fpx.de/fp/Software/UUDeview/download/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

RDEPEND="tk? ( dev-lang/tk )"

DEPEND="${RDEPEND}
	sys-devel/autoconf"

src_compile() {
	autoconf || die

	local myconf

	if use debug; then
		myconf="--disable-optimize"
	else
		myconf="--enable-optimize"
	fi

	if use tk
	then
		myconf="${myconf} --enable-tk"
	fi

	econf \
		`use_enable tk tcl` \
		`use_enable debug optimize` \
		${myconf} || die
	emake || die "emake failed"
}

src_install() {
	einstall MANDIR="${ED}/usr/share/man/" || die
	dodoc HISTORY INSTALL README
}
