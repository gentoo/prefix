# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/t1lib/t1lib-5.1.2.ebuild,v 1.11 2010/01/31 16:07:27 armin76 Exp $

inherit eutils flag-o-matic libtool toolchain-funcs

DESCRIPTION="A Type 1 Font Rasterizer Library for UNIX/X11"
HOMEPAGE="ftp://metalab.unc.edu/pub/Linux/libs/graphics/"
SRC_URI="ftp://sunsite.unc.edu/pub/Linux/libs/graphics/${P}.tar.gz"

LICENSE="LGPL-2 GPL-2"
SLOT="5"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="X doc"

RDEPEND="X? ( x11-libs/libXaw
			x11-libs/libX11
			x11-libs/libXt )"
DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )
	X? ( x11-libs/libXfont
		x11-proto/xproto
		x11-proto/fontsproto )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-5.1.1-parallel.patch
	epatch "${FILESDIR}"/${PN}-do-not-install-t1lib_doc.patch

	sed -i -e "s:dvips:#dvips:" "${S}"/doc/Makefile.in
	sed -i -e "s:\./\(t1lib\.config\):/etc/t1lib/\1:" "${S}"/xglyph/xglyph.c
	# Needed for sane .so versionning on fbsd. Please don't drop.
	elibtoolize
}

src_compile() {
	local myopt=""
	tc-export CC

	use alpha && append-flags -mieee

	if ! use doc; then
		myopt="without_doc"
	else
		VARTEXFONTS=${T}/fonts
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
	if use doc; then
		cd doc
		insinto /usr/share/doc/${PF}
		doins *.pdf *.dvi
	fi
}
