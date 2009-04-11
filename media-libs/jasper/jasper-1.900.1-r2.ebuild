# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jasper/jasper-1.900.1-r2.ebuild,v 1.4 2008/11/09 12:02:37 vapier Exp $

inherit libtool eutils

DESCRIPTION="software-based implementation of the codec specified in the JPEG-2000 Part-1 standard"
HOMEPAGE="http://www.ece.uvic.ca/~mdadams/jasper/"
SRC_URI="http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-${PV}.zip
	mirror://gentoo/${P}-CVE-2008-3520+1+2.patch.bz2"

LICENSE="JasPer2.0"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="opengl jpeg"

RDEPEND="jpeg? ( media-libs/jpeg )"
DEPEND="${RDEPEND}
		app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-overflow-fix.patch
	epatch "${WORKDIR}"/${P}-CVE-2008-3520+1+2.patch

	elibtoolize
}

src_compile() {
	econf \
		$(use_enable jpeg libjpeg) \
		$(use_enable opengl) \
		--enable-shared \
		|| die
	emake || die "If you got undefined references to OpenGL related libraries,please try 'eselect opengl set xorg-x11' before emerging. See bug #133609."
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc NEWS README doc/*
}

pkg_postinst() {
	elog
	elog "Be noted that API has been changed, and you need to run"
	elog "revdep-rebuild from gentoolkit to correct deps."
	elog
}
