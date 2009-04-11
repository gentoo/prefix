# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/antiword/antiword-0.37.ebuild,v 1.11 2008/12/30 20:57:48 angelos Exp $

inherit eutils toolchain-funcs

IUSE="kde"
PATCHVER=0.1
DESCRIPTION="free MS Word reader"
HOMEPAGE="http://www.winfield.demon.nl"
SRC_URI="http://www.winfield.demon.nl/linux/${P}.tar.gz
	mirror://gentoo/${P}-gentoo-${PATCHVER}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"

PATCHDIR=${WORKDIR}/gentoo-antiword/patches

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="diff" \
		epatch ${PATCHDIR}
	epatch "${FILESDIR}"/${P}-prefix.patch
}

src_compile() {
	emake PREFIX="${EPREFIX}" OPT="${CFLAGS}" CC="$(tc-getCC)" LD="$(tc-getCC)" \
		LDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_install() {
	# no configure, so use the prefix in the install here
	make PREFIX="${EPREFIX}" DESTDIR="${D}" global_install || die

	use kde || rm -f "${ED}"/usr/bin/kantiword

	insinto /usr/share/${PN}/examples
	doins Docs/testdoc.doc Docs/antiword.php

	cd Docs
	doman antiword.1
	dodoc COPYING ChangeLog Exmh Emacs FAQ History Netscape \
	QandA ReadMe Mozilla Mutt
}
