# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gocr/gocr-0.47.ebuild,v 1.1 2009/04/29 22:53:15 aballier Exp $

inherit eutils

DESCRIPTION="An OCR (Optical Character Recognition) reader"
HOMEPAGE="http://jocr.sourceforge.net"
SRC_URI="mirror://sourceforge/jocr/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc tk"

DEPEND=">=media-libs/netpbm-9.12
	doc? ( >=media-gfx/transfig-3.2 virtual/ghostscript )
	gtk? ( =x11-libs/gtk+-1*
	       media-gfx/imagemagick )
	tk? ( dev-lang/tk )"

DOCS="AUTHORS BUGS CREDITS HISTORY RE* TODO"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-makefile.patch"
}

src_compile() {
	local mymakes="src man"

	use doc && mymakes="${mymakes} doc examples"

	econf || die "econf failed"
	make ${mymakes} || die "make ${mymakes} failed"
}

src_install() {
	make DESTDIR="${D}" prefix="${EPREFIX}/usr"  exec_prefix="${EPREFIX}/usr" install || die "make install failed"
	# remove the tk frontend if tk is not selected
	use tk || rm "${ED}"/usr/bin/gocr.tcl
	# and install the documentation and examples
	if use doc ; then
		DOCS="${DOCS} doc/gocr.html doc/examples.txt doc/unicode.txt"
		insinto /usr/share/doc/${P}/examples
		doins "${S}"/examples/*.{fig,tex,pcx}
	fi
	# and then install all the docs
	dodoc ${DOCS}
}
