# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdread/libdvdread-4.1.3-r1.ebuild,v 1.2 2009/08/21 20:22:48 ssuominen Exp $

EAPI="1"

inherit eutils multilib

DESCRIPTION="Library for DVD navigation tools"
HOMEPAGE="http://www.mplayerhq.hu/"
SRC_URI="mirror://mplayer/releases/dvdnav/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="+css debug"

DEPEND="!<=media-libs/libdvdnav-4.1.2"
RDEPEND="${DEPEND}
	css? ( media-libs/libdvdcss )"

src_compile() {
	./configure2 --prefix=/usr --libdir=/usr/$(get_libdir) \
		--shlibdir=/usr/$(get_libdir) --enable-static --enable-shared \
		--disable-strip --disable-opts $(use_enable debug) \
		--extra-cflags="${CFLAGS}" --extra-ldflags="${LDFLAGS}" \
		|| die "configure2 died"
	emake version.h || die "emake version.h died"
	emake || die "emake died"
}

src_install () {
	emake -j1 DESTDIR="${D}" install || die "emake install died"
	dodoc AUTHORS DEVELOPMENT-POLICY.txt ChangeLog TODO README
}
