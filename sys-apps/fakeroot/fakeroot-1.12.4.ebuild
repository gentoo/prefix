# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/fakeroot/fakeroot-1.12.4.ebuild,v 1.1 2009/06/25 22:32:12 vapier Exp $

DESCRIPTION="Run commands in an environment faking root privileges"
HOMEPAGE="http://packages.qa.debian.org/f/fakeroot.html"
SRC_URI="mirror://debian/pool/main/f/fakeroot/${PF/-/_}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="test"

RDEPEND=""
DEPEND="test? ( app-arch/sharutils )"

src_install() {
	emake DESTDIR="${D}" install || die "install problem"
	dodoc AUTHORS BUGS ChangeLog DEBUG NEWS README*
}
