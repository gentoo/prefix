# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/geos/geos-3.0.0.ebuild,v 1.1 2008/01/04 17:03:22 bicatali Exp $

EAPI="prefix"

inherit eutils

MY_P=${PN}-${PV/_/}

DESCRIPTION="Geometry engine library for Geographic Information Systems"
HOMEPAGE="http://geos.refractions.net"
SRC_URI="http://geos.refractions.net/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x86"
IUSE="doc python ruby"

RDEPEND="ruby? ( virtual/ruby )
	python? ( virtual/python )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )\
	ruby?  ( >=dev-lang/swig-1.3.29 )
	python? ( >=dev-lang/swig-1.3.29 )"

S="${WORKDIR}/${MY_P}"

src_compile() {
	local myconf

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
	dodoc AUTHORS NEWS README TODO || die
	if use doc; then
		cd "${S}/doc"
		emake doxygen-html || die "doc generation failed"
		dohtml -r doxygen_docs/html/*
	fi
}
