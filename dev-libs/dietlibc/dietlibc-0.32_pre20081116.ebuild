# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dietlibc/dietlibc-0.32_pre20081116.ebuild,v 1.1 2008/11/16 14:13:41 hollow Exp $

inherit eutils flag-o-matic

DESCRIPTION="A minimal libc"
HOMEPAGE="http://www.fefe.de/dietlibc/"
SRC_URI="http://people.linux-vserver.org/~hollow/dietlibc/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND=""

DIETHOME=/usr/diet

pkg_setup() {
	# Replace sparc64 related C[XX]FLAGS (see bug #45716)
	use sparc && replace-sparc64-flags

	# gcc-hppa suffers support for SSP, compilation will fail
	use hppa && strip-unsupported-flags

	# debug flags
	use debug && append-flags -g

	# Makefile does not append CFLAGS
	append-flags -nostdinc -W -Wall -Wextra -Wchar-subscripts \
		-Wmissing-prototypes -Wmissing-declarations -Wno-switch \
		-Wno-unused -Wredundant-decls
}

src_compile() {
	emake prefix="${EPREFIX}"${DIETHOME} CFLAGS="${CFLAGS}" -j1 || die "make failed"
}

src_install() {
	emake prefix="${EPREFIX}"${DIETHOME} DESTDIR="${D}" -j1 install || die "make install failed"
	dobin "${ED}"${DIETHOME}/bin/* || die "dobin failed"
	doman "${ED}"${DIETHOME}/man/*/* || die "doman failed"
	rm -r "${ED}"${DIETHOME}/{man,bin}
	dodoc AUTHOR BUGS CAVEAT CHANGES README THANKS TODO PORTING
}
