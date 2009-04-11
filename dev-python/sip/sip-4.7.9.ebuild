# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sip/sip-4.7.9.ebuild,v 1.7 2009/02/18 20:10:12 jer Exp $

NEED_PYTHON=2.3

inherit python toolchain-funcs versionator multilib eutils

MY_P=${P/_}

DESCRIPTION="A tool for generating bindings for C++ classes so that they can be used by Python"
HOMEPAGE="http://www.riverbankcomputing.co.uk/software/sip/intro"
SRC_URI="http://www.riverbankcomputing.com/static/Downloads/sip$(get_major_version)/${MY_P}.tar.gz"

LICENSE="sip"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug"

S=${WORKDIR}/${MY_P}

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.7.6-darwin-noframework.patch
}

src_compile(){
	python_version

	local myconf
	use debug && myconf="${myconf} -u"

	"${python}" configure.py \
		-p linux-g++ \
		-b "${EPREFIX}/usr/bin" \
		-d "${EPREFIX}/usr/$(get_libdir)/python${PYVER}/site-packages" \
		-e "${EPREFIX}/usr/include/python${PYVER}" \
		-v "${EPREFIX}/usr/share/sip" \
		${myconf} \
		CXXFLAGS_RELEASE="" CFLAGS_RELEASE="" LFLAGS_RELEASE="" \
		CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LFLAGS="${LDFLAGS}" \
		CC=$(tc-getCC) CXX=$(tc-getCXX) \
		LINK=$(tc-getCXX) LINK_SHLIB=$(tc-getCXX) \
		STRIP="true" || die "configure failed"
	emake || die "emake failed"
}

src_install() {
	python_need_rebuild
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog NEWS README TODO doc/sipref.txt
	dohtml doc/*
}

pkg_postinst() {
	python_version
	python_mod_compile "$(python_get_sitedir)"/sip*.py
}

pkg_postrm() {
	python_mod_cleanup
}
