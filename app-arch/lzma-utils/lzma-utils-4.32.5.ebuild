# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.5.ebuild,v 1.8 2008/04/03 18:19:14 armin76 Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/lzma-${PV/_}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!app-arch/lzma"

S=${WORKDIR}/lzma-${PV/_}

pkg_setup() {
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.32.4-interix.patch
	epatch "${FILESDIR}"/${P}-irix.patch
	epatch "${FILESDIR}"/${PN}-io.patch

	# can't run eautoreconf here, would introduce a circular dependency, since
	# m4 needs us (its sources come in lzma format)
#	AT_M4DIR="m4" eautoreconf # need recent libtool for interix

	# instead, patch in what would be done by eautoreconf. No need to keep
	# diffs for config.guess/config.sub, econf updates them anyway.
	# We have gzip already, or we weren't able to unpack ${A}.
	epatch "${FILESDIR}"/${P}-${PR}-eautoreconf.patch.gz
	touch config.h.in # avoid the need for autoheader
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
