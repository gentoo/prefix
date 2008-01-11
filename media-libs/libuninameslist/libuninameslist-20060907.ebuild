# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libuninameslist/libuninameslist-20060907.ebuild,v 1.2 2008/01/10 16:42:35 grobian Exp $

EAPI="prefix"

S=${WORKDIR}/${PN}

DESCRIPTION="Library of unicode annotation data"
SRC_URI="mirror://sourceforge/libuninameslist/${PN}_src-${PV}.tgz"
HOMEPAGE="http://libuninameslist.sourceforge.net/"

LICENSE="BSD"

SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
DEPEND=""
RDEPEND=""
IUSE=""

src_install() {
	# emake install causes an access violation
	einstall || die
}
