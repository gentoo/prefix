# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxklavier/libxklavier-4.0.ebuild,v 1.13 2010/01/16 17:07:57 armin76 Exp $

inherit autotools eutils

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
	>=dev-libs/glib-2.16
	>=dev-libs/libxml2-2.0
	app-text/iso-codes"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.4 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-tests.patch
	rm -v m4/{libtool,lt*}.m4 || die "libtool compability failed"
	eautoreconf
}

src_compile() {
	local xkbbase

	# see bug #113108
	if has_version x11-apps/xkbcomp; then
		xkbbase=/usr/share/X11/xkb
	else
		xkbbase=/usr/$(get_libdir)/X11/xkb
	fi

	econf \
		--disable-static \
		--with-xkb-base="${EPREFIX}"${xkbbase} \
		--with-xkb-bin-base="${EPREFIX}"/usr/bin \
		$(use_enable doc gtk-doc)

	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc AUTHORS CREDITS ChangeLog NEWS README || die "dodoc failed"
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libxklavier.so.12
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libxklavier.so.12
}
