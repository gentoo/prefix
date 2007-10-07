# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/t1lib/t1lib-5.1.1.ebuild,v 1.6 2007/10/05 23:15:27 dirtyepic Exp $

EAPI="prefix"

inherit eutils flag-o-matic libtool toolchain-funcs

DESCRIPTION="A Type 1 Font Rasterizer Library for UNIX/X11"
HOMEPAGE="ftp://metalab.unc.edu/pub/Linux/libs/graphics/"
SRC_URI="ftp://sunsite.unc.edu/pub/Linux/libs/graphics/${P}.tar.gz"

LICENSE="LGPL-2 GPL-2"
SLOT="5"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-solaris"
IUSE="X doc"

RDEPEND="X? ( x11-libs/libXaw
			x11-libs/libX11
			x11-libs/libXt )"
DEPEND="${RDEPEND}
	doc? ( virtual/tetex )
	X? ( x11-libs/libXfont
		x11-proto/xproto
		x11-proto/fontsproto )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-5.0.2-SA26241_buffer_overflow.patch
	epatch "${FILESDIR}/${P}-qa.diff"
	epatch "${FILESDIR}"/${P}-parallel.patch

	sed -i -e "s:dvips:#dvips:" "${S}"/doc/Makefile.in
	sed -i -e "s:\./\(t1lib\.config\):/etc/t1lib/\1:" "${S}"/xglyph/xglyph.c
}

src_compile() {
	local myopt=""
	tc-export CC

	use alpha && append-flags -mieee

	if ! use doc; then
		myopt="without_doc"
	else
		addwrite /var/cache/fonts
	fi

	econf \
		--datadir="${EPREFIX}"/etc \
		$(use_with X x) \
		|| die "econf failed."

	emake ${myopt} || die "emake failed."
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed."
	dodoc Changes README*
	if use doc ; then
		cd doc
		insinto /usr/share/doc/${PF}
		doins *.pdf *.dvi
	fi
}

pkg_postinst() {
	ewarn
	ewarn "You may have to rebuild other packages depending on t1lib."
	ewarn "You may use revdep-rebuild (from app-portage/gentoolkit)"
	ewarn "to do all necessary tricks."
	ewarn
}
