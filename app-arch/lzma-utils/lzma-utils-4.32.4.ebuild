# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.4.ebuild,v 1.3 2008/01/26 06:29:56 vapier Exp $

EAPI="prefix"

inherit eutils autotools flag-o-matic

DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/lzma-${PV/_}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!app-arch/lzma"

S=${WORKDIR}/lzma-${PV/_}

pkg_setup() {
	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=20366
	[[ ${CHOST} == *-aix* ]] && export ac_cv_sys_large_files=no
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gcc-4.3.patch #207338
	epatch "${FILESDIR}"/${P}-interix.patch

	AT_M4DIR="m4" eautoreconf # need recent libtool for interix
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	econf
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
