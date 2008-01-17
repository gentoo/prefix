# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/shared-mime-info/shared-mime-info-0.22-r1.ebuild,v 1.8 2007/12/11 10:57:39 vapier Exp $

EAPI="prefix"

inherit fdo-mime eutils

DESCRIPTION="The Shared MIME-info Database specification"
HOMEPAGE="http://www.freedesktop.org/software/shared-mime-info"
SRC_URI="http://www.freedesktop.org/~hadess/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.3.2
	>=dev-libs/libxml2-2.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix html files showing up as netscape bookmark files; bug #198118
	epatch "${FILESDIR}"/${P}-html-fix.patch
}

src_compile() {
	econf --disable-update-mimedb
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog NEWS README
	# in prefix, install an env.d entry such that prefix patch is used/added
	dodir etc/env.d
	echo "XDG_DATA_DIRS=${EPREFIX}/usr/share" > "${ED}"/etc/env.d/50mimeinfo
}

pkg_postinst() {

	export XDG_DATA_DIRS="${EPREFIX}"/usr/share
	fdo-mime_mime_database_update

}

# FIXME :
# This ebuild should probably also remove the stuff it now leaves behind
# in /usr/share/mime
