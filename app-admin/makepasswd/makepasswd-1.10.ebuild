# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-admin/makepasswd/makepasswd-1.10.ebuild,v 1.22 2005/01/01 11:10:29 eradicator Exp $

EAPI="prefix"

DESCRIPTION="Random password generator"
HOMEPAGE="http://packages.debian.org/stable/admin/makepasswd.html"
SRC_URI="mirror://debian/dists/potato/main/source/admin/${P/-/_}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND="dev-lang/perl"

src_install() {
	dobin makepasswd || die
	doman makepasswd.1
	dodoc README CHANGES
}
