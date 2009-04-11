# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.23.ebuild,v 1.8 2008/11/04 09:37:09 vapier Exp $

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

src_compile() {
	local myconf

	use ppc64 && use hardened && replace-flags -O[2-3] -O1

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	use elibc_FreeBSD && myconf="${myconf} --enable-indirect-deps"

	if [[ ${CHOST} == *-interix* ]]; then 
		export ac_cv_func_poll=no
	fi

	econf ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README
	
}
