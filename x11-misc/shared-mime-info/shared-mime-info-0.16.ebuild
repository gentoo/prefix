# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-misc/shared-mime-info/Attic/shared-mime-info-0.16.ebuild,v 1.14 2006/12/04 16:08:52 foser dead $

EAPI="prefix"

inherit eutils fdo-mime

DESCRIPTION="The Shared MIME-info Database specification"
HOMEPAGE="http://www.freedesktop.org/software/shared-mime-info"
SRC_URI="http://www.freedesktop.org/~jrb/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

RDEPEND=">=dev-libs/glib-2
	>=dev-libs/libxml2-2.4"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.29"

src_unpack() {
	unpack ${A}
	cd ${S}

	sed -i -e 's:libdir=${exec_prefix}/lib:libdir=@libdir@:' ${PN}.pc.in
}

src_compile() {

	econf --disable-update-mimedb || die
	emake || die

}

src_install() {

	make DESTDIR=${D} install || die

	dodoc ChangeLog NEWS README

}

pkg_postinst() {

	fdo-mime_mime_database_update

}

# FIXME :
# This ebuild should probably also remove the stuff it now leaves behind
# in /usr/share/mime
