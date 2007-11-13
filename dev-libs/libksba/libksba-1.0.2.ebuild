# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libksba/libksba-1.0.2.ebuild,v 1.11 2007/11/12 05:36:09 alonbl Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs

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

src_compile() {
	# bug#198648
	if [ $(tc-arch) = "amd64" ]; then
		replace-flags "-O2" "-O0"
		replace-flags "-O3" "-O0"
	fi
	econf || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}
