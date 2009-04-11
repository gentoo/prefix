# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpeg2/libmpeg2-0.4.1.ebuild,v 1.12 2007/10/26 00:49:21 beandog Exp $

inherit eutils libtool

MY_P="mpeg2dec-${PV}"
DESCRIPTION="library for decoding mpeg-2 and mpeg-1 video"
HOMEPAGE="http://libmpeg2.sourceforge.net/"
SRC_URI="http://libmpeg2.sourceforge.net/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="sdl X"

RDEPEND="sdl? ( media-libs/libsdl )
	X? (
		x11-libs/libXv
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXt
	)"
DEPEND="${RDEPEND}
	X? ( x11-proto/xextproto )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix problem that the test for external symbols
	# uses nm which also displays hidden symbols. Bug #130831
	# Don't do this on platforms where scanelf doesn't exist
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*bsd*)
			epatch "${FILESDIR}"/${P}-use-readelf-for-test.patch
		;;
	esac

	elibtoolize
}

src_compile() {
	econf \
		--enable-shared \
		--disable-dependency-tracking \
		$(use_enable sdl) \
		$(use_with X x) \
		${myconf} \
		|| die
	emake \
		OPT_CFLAGS="${CFLAGS}" \
		MPEG2DEC_CFLAGS="${CFLAGS}" \
		LIBMPEG2_CFLAGS="" \
		|| die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
