# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.6.ebuild,v 1.1 2008/05/31 07:56:43 vapier Exp $

EAPI="prefix"

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

inherit eutils flag-o-matic

MY_P="lzma-${PV/_}"
DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/${MY_P}.tar.gz
	nocxx? ( mirror://gentoo/${P}-nocxx.patch.bz2 )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nocxx"

RDEPEND="!app-arch/lzma"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if use nocxx ; then
		epatch "${WORKDIR}"/${P}-nocxx.patch
		find -type f -print0 | xargs -0 touch -r configure
		epunt_cxx
	fi

	# can't run eautoreconf here, would introduce a circular dependency, since
	# m4 needs us (its sources come in lzma format)
#	AT_M4DIR="m4" eautoreconf # need recent libtool for interix

	# instead, patch in what would be done by eautoreconf. No need to keep
	# diffs for config.guess/config.sub, econf updates them anyway.
	# We have gzip already, or we weren't able to unpack ${A}.
#	epatch "${FILESDIR}"/${P}-${PR}-eautoreconf.patch.gz
#	touch config.h.in # avoid the need for autoheader
}

pkg_setup() {
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"
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
