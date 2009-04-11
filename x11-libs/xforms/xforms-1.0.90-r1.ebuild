# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xforms/xforms-1.0.90-r1.ebuild,v 1.14 2008/07/05 10:20:07 loki_val Exp $

inherit autotools

DESCRIPTION="A graphical user interface toolkit for X"
HOMEPAGE="http://www.nongnu.org/xforms/"
SRC_URI="http://savannah.nongnu.org/download/xforms/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE="opengl"

DEPEND="
	x11-libs/libICE
	x11-libs/libXpm
	x11-libs/libSM
	x11-proto/xproto
	opengl? ( virtual/opengl )
	media-libs/jpeg"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-as-needed.patch
	epatch "${FILESDIR}"/${P}-Makefile.am.patch
	rm ${S}/config/libtool.m4 ${S}/acinclude.m4
	AT_M4DIR=config eautoreconf
}

src_compile () {
	local myopts
	use opengl || myopts="--disable-gl"

	econf ${myopts} || die "econf failed"
	emake || die "emake failed"
}

src_install () {
	make DESTDIR="${D}" install || die
	dodoc ChangeLog INSTALL NEWS README
}
