# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.6.4-r1.ebuild,v 1.9 2009/01/05 13:26:13 remi Exp $

inherit eutils flag-o-matic libtool

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug directfb doc glitz opengl svg test X xcb aqua"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig
		>=media-libs/freetype-2.1.9
		sys-libs/zlib
		media-libs/libpng
		>=x11-libs/pixman-0.10.0
		X?	(
				x11-libs/libXrender
				x11-libs/libXext
				x11-libs/libX11
				x11-libs/libXft
				xcb? ( x11-libs/libxcb
						x11-libs/xcb-util )
			)
		directfb? ( >=dev-libs/DirectFB-0.9.24 )
		glitz? ( >=media-libs/glitz-0.5.1 )
		svg? ( dev-libs/libxml2 )"

DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19
		X? ( x11-proto/renderproto
			xcb? ( x11-proto/xcb-proto ) )
		doc?	(
					>=dev-util/gtk-doc-1.6
					 ~app-text/docbook-xml-dtd-4.2
				)"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# libpng's API changed as of 1.2.30, this is backwards compat with
	# older libpng's as well. bug #235072
	epatch "${FILESDIR}"/${PN}-1.6.4-libpng-api-change.patch

	# We need to run elibtoolize to ensure correct so versioning on FreeBSD
	elibtoolize
}

src_compile() {
	local use_xcb

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT
	# http://bugs.freedesktop.org/show_bug.cgi?id=15463
	[[ ${CHOST} == *-solaris* ]] && append-flags -D_POSIX_PTHREAD_SEMANTICS

	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	if use glitz && use opengl; then
		export glitz_LIBS=-lglitz-glx
	fi

	use_xcb="--disable-xcb"
	use X && use xcb && use_xcb="--enable-xcb"

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) \
		$(use_enable directfb) ${use_xcb} \
		$(use_enable svg) $(use_enable glitz) $(use_enable X xlib-xrender) \
		$(use_enable debug test-surfaces) --enable-pdf  --enable-png \
		--enable-freetype --enable-ps \
		$(use_enable aqua quartz) $(use_enable aqua atsui) \
		|| die "configure failed"

	emake || die "compile failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README

	# just for 1.6.x (already fixed upstream). Gentoo bug #235660
	if use aqua; then
		insinto /usr/lib/pkgconfig
		doins ${S}/src/cairo-quartz-font.pc || die "install failed"
	fi
}
