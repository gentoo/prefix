# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.13-r1.ebuild,v 1.11 2007/02/08 19:29:24 grobian Exp $

EAPI="prefix"

inherit eutils libtool

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
	epatch ${FILESDIR}/${P}-doxy-stamp-make.patch
	epatch ${FILESDIR}/${P}-pkgconfig.patch

	# The libexif hackers made a goof on the soname versioning.
	sed -i 's/^LIBEXIF_AGE=0$/LIBEXIF_AGE=2/' ${S}/configure
	sed -i 's/^LIBEXIF_REVISION=0$/LIBEXIF_REVISION=2/' ${S}/configure
	sed -i 's/^LIBEXIF_VERSION_INFO=.*$/LIBEXIF_VERSION_INFO=$LIBEXIF_CURRENT:$LIBEXIF_AGE:$LIBEXIF_REVISION/' \
		${S}/configure

	elibtoolize
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

	# Keep around old lib
	preserve_old_lib /usr/$(get_libdir)/libexif.so.9
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libexif.so.9
}
