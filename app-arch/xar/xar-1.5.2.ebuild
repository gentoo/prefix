# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xar/xar-1.5.2.ebuild,v 1.1 2008/01/29 22:45:56 drac Exp $

EAPI="prefix 1"

DESCRIPTION="an easily extensible archive format"
HOMEPAGE="http://code.google.com/p/xar"
SRC_URI="http://xar.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="+bzip2"

# bad. automagic acl and bzip2 linkage.
RDEPEND="dev-libs/openssl
	dev-libs/libxml2
	bzip2? ( app-arch/bzip2 )"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc TODO
}
