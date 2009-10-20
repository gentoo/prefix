# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libotr/libotr-3.2.0.ebuild,v 1.9 2009/10/10 11:35:35 ssuominen Exp $

DESCRIPTION="(OTR) Messaging allows you to have private conversations over instant messaging"
HOMEPAGE="http://www.cypherpunks.ca/otr/"
SRC_URI="http://www.cypherpunks.ca/otr/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.2"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog README
}
