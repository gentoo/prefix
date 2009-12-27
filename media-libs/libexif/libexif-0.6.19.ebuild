# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.19.ebuild,v 1.3 2009/12/16 20:19:06 jer Exp $

EAPI=2
inherit eutils autotools

DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.6.13-pkgconfig.patch
	elibtoolize # FreeBSD .so version
}

src_configure() {
	# Solaris /bin/sh no like
	export CONFIG_SHELL="${EPREFIX}"/bin/bash
	econf \
		--disable-dependency-tracking \
		$(use_enable nls) \
		$(use_enable doc docs) \
		--with-doc-dir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install || die
	rm -f "${ED}"usr/share/doc/${PF}/{ABOUT-NLS,COPYING}
	prepalldocs
}
