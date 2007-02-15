# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.13-r2.ebuild,v 1.2 2007/02/08 06:17:15 nerdboy Exp $

EAPI="prefix"

inherit autotools eutils

DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc nls"

DEPEND="dev-util/pkgconfig
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-doxygen.patch
	epatch ${FILESDIR}/${P}-parallel-build.patch
	epatch ${FILESDIR}/${P}-doxy-stamp-make.patch		# bug #160973
	epatch ${FILESDIR}/${P}-pkgconfig.patch
	epatch ${FILESDIR}/${P}-optional-apidocs.patch		# bug #150152

	# See upstream commits of configure.ac from 1.13 to 1.15
	epatch "${FILESDIR}/${P}-library-versioning.patch"

	AT_M4DIR="m4m" eautoreconf
}

src_compile() {
	local my_conf
	use doc && my_conf="--with-doc-dir=/usr/share/doc/${PF}"
	use nls || my_conf="${my_conf} --without-libintl-prefix"
	econf $(use_enable nls) $(use_enable doc) \
		--with-pic --disable-rpath ${my_conf} || die
	emake || die
}

src_install() {
	dodir /usr/$(get_libdir)
	dodir /usr/include/libexif
	use nls && dodir /usr/share/locale
	use doc && dodir /usr/share/doc/${PF}
	dodir /usr/$(get_libdir)/pkgconfig

	make DESTDIR="${D}" install || die

	dodoc ChangeLog README

	# installs a blank directory for whatever broken reason
	use nls || rm -rf ${ED}usr/share/locale
}

pkg_preinst() {
	# Keep around old lib
	preserve_old_lib /usr/$(get_libdir)/libexif.so.9
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libexif.so.9
}
