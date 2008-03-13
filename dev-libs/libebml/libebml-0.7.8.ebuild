# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libebml/Attic/libebml-0.7.8.ebuild,v 1.1 2008/03/13 00:07:43 beandog Exp $

EAPI="prefix"

DESCRIPTION="Extensible binary format library (kinda like XML)"
HOMEPAGE="http://www.matroska.org/"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_install() {
	cd "${S}"/make/linux
	einstall libdir="${ED}/usr/$(get_libdir)" || die "make install failed"
	dodoc "${S}"/ChangeLog
}
