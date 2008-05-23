# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxklavier/libxklavier-3.6.ebuild,v 1.1 2008/05/22 21:28:38 eva Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="High level XKB library"
HOMEPAGE="http://www.freedesktop.org/Software/LibXklavier"
SRC_URI="mirror://sourceforge/gswitchit/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc"

RDEPEND="|| ( x11-misc/xkeyboard-config x11-misc/xkbdata )
		 x11-libs/libX11
		 x11-apps/xkbcomp
		 x11-libs/libxkbfile
		 >=dev-libs/glib-2.6
		 >=dev-libs/libxml2-2.0
		 app-text/iso-codes"
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		doc? ( app-doc/doxygen )"

src_compile() {
	local xkbbase

	# see bug #113108
	if has_version x11-apps/xkbcomp; then
		xkbbase=/usr/share/X11/xkb
	else
		xkbbase=/usr/$(get_libdir)/X11/xkb
	fi

	econf --with-xkb-base="${EPREFIX}"${xkbbase} --with-xkb-bin-base="${EPREFIX}"/usr/bin \
		  $(use_enable doc doxygen) || die

	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die

	insinto /usr/share/libxklavier
	use sparc && doins "${FILESDIR}/sun.xml"

	dodoc AUTHORS CREDITS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed!"
	ewarn "If you are upgrading from a version prior to 3.4 you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn "revdep-rebuild -X --library libxklavier.so.11"
}
