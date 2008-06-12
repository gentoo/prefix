# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.22.ebuild,v 1.10 2007/12/11 17:15:49 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils

MY_PN="pkg-config"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"

SRC_URI="http://pkgconfig.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="hardened elibc_FreeBSD"

DEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${MY_PN}-0.21-fix-tests.patch"
	epatch "${FILESDIR}"/${MY_P}-interix.patch

	use ppc64 && use hardened && replace-flags -O[2-3] -O1
}

src_compile() {
	local myconf

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	use elibc_FreeBSD && myconf="${myconf} --enable-indirect-deps"

	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	econf ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README
	
}
