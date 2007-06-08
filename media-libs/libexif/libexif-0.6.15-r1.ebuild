# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.15-r1.ebuild,v 1.2 2007/06/05 08:39:38 eradicator Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="doc nls"

DEPEND="dev-util/pkgconfig
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext )"

RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${PN}-0.6.13-pkgconfig.patch

	# We do this for sane .so versioning on FreeBSD
	elibtoolize
}

src_compile() {
	local my_conf="--with-doc-dir=/usr/share/doc/${PF}"
	use nls || my_conf="${my_conf} --without-libintl-prefix"
	econf $(use_enable nls) $(use_enable doc docs) \
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

pkg_postinst() {
	elog "If you are upgrading from a version of libexif older than 0.6.13-r2,"
	elog "you will need to do the following to rebuild dependencies:"
	elog "# revdep-rebuild --soname libexif.so.9"
	elog "# revdep-rebuild --soname libexif.so.10"
	elog ""
	elog "Note, it is actually safe to create a symlink from libexif.so.10 to"
	elog "libexif.so.12 if you need to during the update."
}

