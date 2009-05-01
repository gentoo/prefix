# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/file-5.01.ebuild,v 1.1 2009/05/01 01:56:54 vapier Exp $

inherit eutils distutils autotools flag-o-matic

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE="python"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-4.15-libtool.patch #99593
	epatch "${FILESDIR}"/${PN}-5.00-interix.patch
	epatch "${FILESDIR}"/${PN}-5.00-strtoull-limits.patch #263527

	eautoreconf # required for interix, was elibtoolize
	epunt_cxx

	# make sure python links against the current libmagic #54401
	sed -i "/library_dirs/s:'\.\./src':'../src/.libs':" python/setup.py
	# dont let python README kill main README #60043
	mv python/README{,.python}

	# only one data file, so put it into /usr/share/misc/
#	sed -i '/^pkgdatadir/s:/@PACKAGE@::' $(find -name Makefile.in)
}

src_compile() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	econf || die
	emake || die

	use python && cd python && distutils_src_compile
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog MAINT README

	use python && cd python && distutils_src_install
}

pkg_postinst() {
	use python && distutils_pkg_postinst
}

pkg_postrm() {
	use python && distutils_pkg_postrm
}
