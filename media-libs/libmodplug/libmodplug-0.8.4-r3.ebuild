# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmodplug/libmodplug-0.8.4-r3.ebuild,v 1.1 2008/04/14 14:06:31 flameeyes Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools

DESCRIPTION="Library for playing MOD-like music files"
SRC_URI="mirror://sourceforge/modplug-xmms/${P}.tar.gz"
HOMEPAGE="http://modplug-xmms.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
#-sparc: 1.0 - Bus Error on play
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.7-amd64.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-timidity-patches.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-ppc64-64ul.patch"
	epatch "${FILESDIR}/${PN}-0.8.4-endian.patch"

	sed -i -e 's:-ffast-math::' "${S}/configure.in"

	eautoreconf
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README TODO

	# Remove unneeded libtool files
	find "${ED}" -name '*.la' -delete
}

pkg_postinst() {
	elog "Since version 0.8.4 onward, libmodplug supports MIDI playback."
	elog "unfortunately to work correctly, this needs timidity patches,"
	elog "but the code does not support the needed 'source' directive to"
	elog "work with the patches currently in portage. For this reason it"
	elog "will not work as intended yet."
}
