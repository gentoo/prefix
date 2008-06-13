# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/file-4.23.ebuild,v 1.7 2008/03/29 15:23:34 ranger Exp $

EAPI="prefix"

inherit eutils distutils flag-o-matic autotools

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="python"

DEPEND=""

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-4.15-libtool.patch #99593

	# on interix there is no strtoull implementation, so patch one in.
	epatch "${FILESDIR}"/${P}-strtoull.patch
	# interix 3.5 need stddef for intptr_t
	epatch "${FILESDIR}"/${P}-intptr_t.patch

	# make sure python links against the current libmagic #54401
	sed -i "/library_dirs/s:'\.\./src':'../src/.libs':" python/setup.py

	# dont let python README kill main README #60043
	mv python/README{,.python}

	eautoreconf
	epunt_cxx
}

src_compile() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	econf --datadir="${EPREFIX}"/usr/share/misc || die
	emake || die "emake failed"

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
