# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libaio/libaio-0.3.107.ebuild,v 1.12 2009/05/06 17:03:18 jer Exp $

inherit eutils multilib toolchain-funcs

DESCRIPTION="Asynchronous input/output library that uses the kernels native interface"
HOMEPAGE="http://www.kernel.org/pub/linux/kernel/people/andrea/libaio/ http://lse.sourceforge.net/io/aio.html"
# Rip out of src rpm that Redhat uses:
# http://download.fedora.redhat.com/pub/fedora/linux/core/development/source/SRPMS/
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-sparc.patch
	epatch "${FILESDIR}"/${P}-install-to-slash.patch
	epatch "${FILESDIR}"/${PN}-0.3.107-ar-ranlib.patch
	epatch "${FILESDIR}"/${PN}-0.3.106-build.patch
	epatch "${FILESDIR}"/${PN}-0.3.107-generic-arch.patch
	sed -i "/^libdir=/s:lib$:$(get_libdir):" src/Makefile Makefile
	sed -i "/^prefix=/s:/usr:${EPREFIX}/usr:" src/Makefile Makefile
}

src_compile() {
	tc-export AR CC RANLIB
	emake || die "emake failed"
}

src_test() {
	cd "${S}"/harness
	mkdir testdir
	emake check prefix="${S}/src" libdir="${S}/src"
}

src_install() {
	emake install DESTDIR="${D}" || die
	doman man/*
	dodoc ChangeLog TODO

	# remove stuff provided by man-pages now
	rm "${ED}"usr/share/man/man3/aio_{cancel,error,fsync,read,return,suspend,write}.*
}
