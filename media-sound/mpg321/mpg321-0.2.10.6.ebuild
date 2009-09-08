# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg321/mpg321-0.2.10.6.ebuild,v 1.10 2009/09/06 16:59:03 ssuominen Exp $

EAPI=2
inherit autotools

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://packages.debian.org/mpg321"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="alsa"

RDEPEND="sys-libs/zlib
	media-libs/libmad
	media-libs/libid3tag
	media-libs/libao[alsa?]"
DEPEND="${RDEPEND}"

src_prepare() {
	AT_M4DIR=m4 eautoreconf
}

src_configure() {
	local myao=oss
	use alsa && myao=alsa09

	econf \
		--disable-dependency-tracking \
		--disable-mpg123-symlink \
		--with-default-audio=${myao}
}

src_install() {
	emake DESTDIR="${D}" install || die
	newdoc debian/changelog ChangeLog.debian
	dodoc AUTHORS BUGS HACKING NEWS README{,.remote} THANKS TODO
}
