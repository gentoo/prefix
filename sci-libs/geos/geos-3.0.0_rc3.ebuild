# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/geos/geos-3.0.0_rc3.ebuild,v 1.2 2006/12/16 11:11:54 dev-zero Exp $

EAPI="prefix"

inherit eutils

MY_P=${PN}-${PV/_/}

DESCRIPTION="Geometry Engine - Open Source"
HOMEPAGE="http://geos.refractions.net"
SRC_URI="http://geos.refractions.net/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86"
IUSE="doc python ruby"

RDEPEND="ruby? ( virtual/ruby )
	python? ( virtual/python )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )\
	ruby?  ( >=dev-lang/swig-1.3.29 )
	python? ( >=dev-lang/swig-1.3.29 )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-amd64.patch"
}

src_compile() {
	local myconf="--with-pic"

	if ! use python && ! use ruby ; then
		myconf="--disable-swig"
	fi

	econf ${myconf} \
		$(use_enable python) \
		$(use_enable ruby) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	into /usr
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README TODO
	if use doc; then
		cd "${S}/doc"
		emake doxygen-html || die "doc generation failed"
		dohtml -r doxygen_docs/html/*
	fi
}
