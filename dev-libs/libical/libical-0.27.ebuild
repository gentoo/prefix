# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libical/libical-0.27.ebuild,v 1.1 2008/01/24 10:22:30 drac Exp $

EAPI="prefix"

DESCRIPTION="a implementation of basic iCAL protocols from citadel, previously known as aurore."
HOMEPAGE="http://www.citadel.org"
SRC_URI="http://easyinstall.citadel.org/${P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TEST THANKS TODO doc/*.txt
}
