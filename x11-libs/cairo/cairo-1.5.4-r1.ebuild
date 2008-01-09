# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.5.4-r1.ebuild,v 1.1 2007/12/27 14:19:03 cardoe Exp $

EAPI="prefix"

inherit eutils flag-o-matic libtool

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="aqua debug directfb doc glitz opengl svg X xcb test"

RDEPEND="!aqua? (
			media-libs/fontconfig
			>=media-libs/freetype-2.1.4
		)
		>=x11-libs/pixman-0.9.4
		sys-libs/zlib
		media-libs/libpng
		X?	(
				x11-libs/libXrender
				x11-libs/libXext
				x11-libs/libX11
				virtual/xft
				xcb? ( x11-libs/libxcb
						x11-libs/xcb-util )
			)
		directfb? ( >=dev-libs/DirectFB-0.9.24 )
		glitz? ( >=media-libs/glitz-0.5.1 )
		svg? ( dev-libs/libxml2 )"

DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19
		test? (
				virtual/ghostscript
				>=app-text/poppler-bindings-0.4.1
				x11-libs/pango
				x11-libs/gtk+
				svg? ( >=gnome-base/librsvg-2.15.0 )
			)
		X? ( x11-proto/renderproto
			xcb? ( x11-proto/xcb-proto ) )
		doc?	(
					>=dev-util/gtk-doc-1.6
					 ~app-text/docbook-xml-dtd-4.2
				)"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# SPARC alignment patch
	epatch "${FILESDIR}"/${P}-sparc-alignment.patch

	# We need to run elibtoolize to ensure correct so versioning on FreeBSD
	elibtoolize
}

src_compile() {
	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	if use glitz && use opengl; then
		export glitz_LIBS=-lglitz-glx
	fi

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) \
	  	  $(use_enable directfb) \
		  $(use_enable svg) $(use_enable glitz) $(use_enable X xlib-xrender) \
		  $(use_enable debug test-surfaces) --enable-pdf  --enable-png \
		  $(use_enable !aqua freetype) --enable-ps $(use_enable xcb) \
		  $(use_enable aqua quartz) $(use_enable aqua atsui) \
		  || die "configure failed"

	emake || die "compile failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
