# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/dirac/dirac-1.0.2.ebuild,v 1.8 2009/05/30 09:17:32 ulm Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools

DESCRIPTION="Open Source video codec"
HOMEPAGE="http://dirac.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="mmx debug doc"

DEPEND="doc? ( app-doc/doxygen
	virtual/latex-base
	media-gfx/graphviz
	|| ( app-text/dvipdfm
		app-text/ptex )
		)"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.5.2-doc.patch"

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	econf \
		$(use_enable mmx) \
		$(use_enable debug) \
		$(use_enable doc) \
		|| die "econf failed"

	VARTEXFONTS="${T}/fonts" emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		latexdir="${EPREFIX}/usr/share/doc/${PF}/programmers" \
		algodir="${EPREFIX}/usr/share/doc/${PF}/algorithm" \
		faqdir="${EPREFIX}/usr/share/doc/${PF}" \
		install || die "emake install failed"

	dodoc README AUTHORS NEWS TODO ChangeLog
}
