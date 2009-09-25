# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/arj/arj-3.10.22-r2.ebuild,v 1.9 2009/09/23 15:09:53 patrick Exp $

inherit autotools eutils toolchain-funcs

PATCH_LEVEL=4

DESCRIPTION="Utility for opening arj archives"
HOMEPAGE="http://arj.sourceforge.net"
SRC_URI="mirror://debian/pool/main/a/arj/${P/-/_}.orig.tar.gz
	mirror://debian/pool/main/a/arj/${P/-/_}-${PATCH_LEVEL}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P/-/_}-${PATCH_LEVEL}.diff \
		"${FILESDIR}"/${P}-implicit-declarations.patch
	epatch "${FILESDIR}/${P}-glibc2.10.patch"

	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" \
		epatch debian/patches

	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-interix.patch

	cd gnu
	eautoconf
}

src_compile() {
	cd gnu
	CFLAGS="${CFLAGS} -Wall" econf

	cd "${S}"
	sed -i -e '/stripgcc/d' GNUmakefile || die "sed failed."

	ARJLIBDIR="${EPREFIX}/usr/$(get_libdir)"

	emake CC=$(tc-getCC) libdir="${ARJLIBDIR}" \
		pkglibdir="${ARJLIBDIR}" all || die "emake failed."
}

src_install() {
	emake pkglibdir="${ARJLIBDIR}" \
		DESTDIR="${D}" install || die "emake install failed."

	dodoc doc/rev_hist.txt
}
