# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.7.ebuild,v 1.7 2008/10/27 22:29:04 ranger Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

inherit eutils libtool

MY_P="lzma-${PV/_}"
DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/${MY_P}.tar.gz
	nocxx? ( mirror://gentoo/${PN}-4.32.6-nocxx.patch.bz2 )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nocxx"

RDEPEND="!app-arch/lzma
	!<app-arch/p7zip-4.57"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if use nocxx ; then
		epatch "${WORKDIR}"/${PN}-4.32.6-nocxx.patch
		find -type f -print0 | xargs -0 touch -r configure
		epunt_cxx
	fi

	epatch "${FILESDIR}"/${PN}-4.32.6-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${PN}-4.32.5-mint.patch
	elibtoolize # for ia64-hpux
}

pkg_setup() {
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_utimes=no
	fi
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
	use nocxx && newbin "${FILESDIR}"/lzma-nocxx.sh lzma
}

pkg_postinst() {
	if use nocxx ; then
		ewarn "You have a neutered lzma package install due to USE=nocxx."
		ewarn "You will only be able to unpack lzma archives."
	fi
}
