# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xclip/xclip-0.08-r2.ebuild,v 1.11 2009/01/18 23:09:50 nelchael Exp $

inherit eutils

DESCRIPTION="Command-line utility to read data from standard in and place it in an X selection"
SRC_URI="http://people.debian.org/~kims/${PN}/${P}.tar.gz
	mirror://debian/pool/main/x/${PN}/${PN}_${PV}-7.diff.gz"
HOMEPAGE="http://people.debian.org/~kims/xclip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

S="${WORKDIR}"/${PN}

RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	app-text/rman
	x11-misc/imake"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${PN}_${PV}-7.diff
}

src_compile() {
	xmkmf || die "xmkmf failed"
	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	emake DESTDIR="${D}" MANPATH="${EPREFIX}"/usr/share/man MANSUFFIX=1 \
		install.man || die "emake install.man failed"

	rm -f "${ED}"/usr/lib/X11/doc/html/*
	find "${ED}" -depth -type d | xargs -n1 rmdir 2>/dev/null
	dodoc README CHANGES
}
