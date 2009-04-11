# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdread/libdvdread-4.1.3_p1168.ebuild,v 1.2 2009/03/09 18:55:16 beandog Exp $

EAPI=2

WANT_AUTOCONF="2.5"
inherit eutils autotools multilib

DESCRIPTION="Library for DVD navigation tools"
HOMEPAGE="http://www.mplayerhq.hu/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="+css"

DEPEND="!<=media-libs/libdvdnav-4.1.2
	css? ( media-libs/libdvdcss )"
RDEPEND="$DEPEND"

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
	eautoreconf
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install died"
	dodoc AUTHORS DEVELOPMENT-POLICY.txt ChangeLog TODO README
}
