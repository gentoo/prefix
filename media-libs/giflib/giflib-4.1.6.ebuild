# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/giflib/giflib-4.1.6.ebuild,v 1.10 2008/02/22 07:15:13 lu_zero Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="Library to handle, display and manipulate GIF images"
HOMEPAGE="http://sourceforge.net/projects/giflib/"
SRC_URI="mirror://sourceforge/giflib/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
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
	epunt_cxx
	eautoreconf # need new libtool for interix
}

src_compile() {
	local myconf="--disable-gl $(use_enable X x11)"
	# prevent circular depend #111455
	if has_version media-libs/urt ; then
		myconf="${myconf} $(use_enable rle)"
	else
		myconf="${myconf} --disable-rle"
	fi
	econf ${myconf}
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS ChangeLog NEWS ONEWS README TODO doc/*.txt
	dohtml -r doc
}
