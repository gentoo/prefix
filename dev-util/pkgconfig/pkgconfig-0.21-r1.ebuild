# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.21-r1.ebuild,v 1.5 2007/04/23 13:58:00 gustavoz Exp $

EAPI="prefix"

inherit flag-o-matic eutils

MY_P="pkg-config"-${PV}
DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"

SRC_URI="http://pkgconfig.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="hardened"

DEPEND=""

S=${WORKDIR}/${MY_P}


src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch ${FILESDIR}/${MY_P}-fix-tests.patch

	use ppc64 && use hardened && replace-flags -O[2-3] -O1
}

src_compile() {
	local myconf

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	use elibc_FreeBSD && myconf="${myconf} --enable-indirect-deps"

	econf ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README
	
}
