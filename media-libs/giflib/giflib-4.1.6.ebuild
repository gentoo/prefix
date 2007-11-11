# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/giflib/giflib-4.1.6.ebuild,v 1.1 2007/11/11 00:38:12 vapier Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="Library to handle, display and manipulate GIF images"
HOMEPAGE="http://sourceforge.net/projects/giflib/"
SRC_URI="mirror://sourceforge/giflib/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="rle X"

DEPEND="!media-libs/libungif
	X? (
		x11-libs/libXt
		x11-libs/libX11
		x11-libs/libICE
		x11-libs/libSM
	)
	rle? ( media-libs/urt )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gif2rle.patch
	elibtoolize
	epunt_cxx
}

src_compile() {
	econf \
		$(use_enable X x11) \
		$(
			# prevent circular depend #111455
			has_version media-libs/urt \
				|| --disable-rle \
				&& use_enable rle \
		) \
		--disable-gl \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS ONEWS README TODO doc/*.txt
	dohtml -r doc
}
