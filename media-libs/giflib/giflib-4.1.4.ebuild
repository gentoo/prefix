# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/giflib/giflib-4.1.4.ebuild,v 1.14 2006/12/30 09:15:47 grobian Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="Library to handle, display and manipulate GIF images"
HOMEPAGE="http://sourceforge.net/projects/libungif/"
SRC_URI="mirror://sourceforge/libungif/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="rle X"

DEPEND="X? ( || ( ( x11-libs/libXt x11-libs/libX11 x11-libs/libICE x11-libs/libSM ) virtual/x11 ) )
	rle? ( media-libs/urt )
	!media-libs/libungif"

src_unpack() {
	unpack ${A}
	elibtoolize
	epunt_cxx
}

yesno() { use $1 && echo yes || echo no ; }
src_compile() {
	export \
		ac_cv_lib_gl_s_main=no \
		ac_cv_lib_rle_rle_hdr_init=$(yesno rle) \
		ac_cv_lib_X11_main=$(yesno X)
	# prevent circular depend #111455
	has_version media-libs/urt || export ac_cv_lib_rle_rle_hdr_init=no
	econf || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS ONEWS README TODO doc/*.txt
	dohtml -r doc
}
