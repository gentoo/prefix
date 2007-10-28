# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libspiff/libspiff-0.8.0.ebuild,v 1.5 2007/10/27 17:27:59 nixnut Exp $

EAPI="prefix"

DESCRIPTION="Library for XSPF playlist reading and writing"
HOMEPAGE="http://libspiff.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="doc"
RDEPEND=">=dev-libs/expat-1.95.8"
DEPEND="${RDEPEND}
	>=dev-libs/uriparser-0.3.3-r1
	doc? ( app-doc/doxygen )"

src_compile() {
	econf || die "configure failed"
	emake || die "emake failed"

	if use doc; then
		ebegin "Creating documentation"
		cd "${S}/doc"
		doxygen Doxyfile
		eend 0
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README AUTHORS ChangeLog

	if use doc; then
		dohtml doc/html/*
	fi
}

pkg_postinst() {
	elog "libspiff-0.8.0 changed its SONAME. Please run # revdep-rebuild to recompile your XSPF applications."
}
