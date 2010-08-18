# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxslt/libxslt-1.1.26.ebuild,v 1.12 2010/01/25 19:29:16 armin76 Exp $

EAPI=2
inherit autotools eutils toolchain-funcs

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="http://www.xmlsoft.org/"
SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt debug python"

DEPEND=">=dev-libs/libxml2-2.6.27
	crypt?  ( >=dev-libs/libgcrypt-1.1.42 )
	python? ( >=dev-lang/python-2.5 )"

src_prepare() {
	epatch "${FILESDIR}"/libxslt.m4-${P}.patch \
		"${FILESDIR}"/${PN}-1.1.23-parallel-install.patch \
		"${FILESDIR}"/${P}-undefined.patch \
		"${FILESDIR}"/${P}-versionscript-solaris.patch
	eautoreconf # also needed for new libtool on Interix
	epunt_cxx
	elibtoolize
}

src_configure() {
	# libgcrypt is missing pkg-config file, so fixing cross-compile
	# here. see bug 267503.
	if tc-is-cross-compiler; then
		export LIBGCRYPT_CONFIG="${SYSROOT}/usr/bin/libgcrypt-config"
	fi

	econf \
		--disable-dependency-tracking \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-html-subdir=html \
		$(use_with crypt crypto) \
		$(use_with python) \
		$(use_with debug) \
		$(use_with debug mem-debug)
}

src_install() {
	emake DESTDIR="${D}" install || die
	mv -vf "${ED}"/usr/share/doc/${PN}-python-${PV} \
		"${ED}"/usr/share/doc/${PF}/python
	dodoc AUTHORS ChangeLog FEATURES NEWS README TODO || die
}
