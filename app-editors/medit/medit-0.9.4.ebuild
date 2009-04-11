# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-editors/medit/medit-0.9.4.ebuild,v 1.1 2009/02/04 18:11:07 patrick Exp $

inherit eutils python fdo-mime gnome2-utils multilib

DESCRIPTION="Multiplatform text editor"
HOMEPAGE="http://mooedit.sourceforge.net"
SRC_URI="mirror://sourceforge/mooedit/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="fam nls pcre python xml"

RDEPEND="fam? ( virtual/fam )
	pcre? ( dev-libs/libpcre )
	python? ( dev-python/pygtk )
	xml? ( dev-libs/libxml2 )
	>=x11-libs/gtk+-2"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	dev-libs/libxslt"

RESTRICT="test"

src_compile() {
	econf $(use_with fam) $(use_with nls) \
		$(use_with python) $(use_with python moo-module) \
		$(use_with python project) $(use_with xml) \
		$(use_with pcre system-pcre) \
		--enable-libmoo --enable-ctags-plugin \
		--disable-generated-files

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS README THANKS
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
	use python && python_mod_optimize /usr/$(get_libdir)/moo/plugins
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
	use python && python_mod_cleanup /usr/$(get_libdir)/moo/plugins
}
