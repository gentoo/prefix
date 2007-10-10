# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libksba/libksba-1.0.2.ebuild,v 1.10 2007/10/09 14:57:54 angelos Exp $

EAPI="prefix"

DESCRIPTION="makes X.509 certificates and CMS easily accessible to applications"
HOMEPAGE="http://www.gnupg.org/(en)/download/index.html#libksba"
SRC_URI="mirror://gnupg/libksba/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/libgpg-error-1.2
	dev-libs/libgcrypt"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}
