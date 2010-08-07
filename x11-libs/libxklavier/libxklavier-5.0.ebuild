# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxklavier/libxklavier-5.0.ebuild,v 1.5 2010/08/01 11:11:13 fauli Exp $

EAPI=2
inherit eutils libtool multilib

DESCRIPTION="High level XKB library"
HOMEPAGE="http://www.freedesktop.org/Software/LibXklavier"
SRC_URI="mirror://sourceforge/gswitchit/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc"

RDEPEND="x11-misc/xkeyboard-config
	x11-libs/libX11
	>=x11-libs/libXi-1.1.3
	x11-apps/xkbcomp
	x11-libs/libxkbfile
	>=dev-libs/glib-2.16:2
	dev-libs/libxml2
	app-text/iso-codes"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.4 )"

src_prepare() {
	elibtoolize
}

src_configure() {
	local xkbbase

	# see bug #113108
	if has_version x11-apps/xkbcomp; then
		xkbbase=/usr/share/X11/xkb
	else
		xkbbase=/usr/$(get_libdir)/X11/xkb
	fi

	econf \
		--disable-dependency-tracking \
		--disable-static \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-xkb-base="${EPREFIX}"${xkbbase} \
		--with-xkb-bin-base="${EPREFIX}"/usr/bin \
		$(use_enable doc gtk-doc)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog CREDITS NEWS README || die
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libxklavier.so.15
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libxklavier.so.15
}
