# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/geos/geos-3.0.3.ebuild,v 1.1 2008/11/27 11:36:57 bicatali Exp $

inherit eutils

DESCRIPTION="Geometry engine library for Geographic Information Systems"
HOMEPAGE="http://geos.refractions.net"
SRC_URI="http://download.osgeo.org/geos/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris"
IUSE="doc python ruby"

RDEPEND="ruby? ( virtual/ruby )
	python? ( virtual/python )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )\
	ruby?  ( >=dev-lang/swig-1.3.29 )
	python? ( >=dev-lang/swig-1.3.29 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-test.patch
}

src_compile() {
	local myconf

	if ! use python && ! use ruby ; then
		myconf="--disable-swig"
	fi

	econf ${myconf} \
		$(use_enable python) \
		$(use_enable ruby)
	emake || die "emake failed"
	if use doc; then
		cd "${S}/doc"
		emake doxygen-html || die "doc generation failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README TODO || die
	if use doc; then
		cd "${S}/doc"
		dohtml -r doxygen_docs/html/* || die
	fi
}
