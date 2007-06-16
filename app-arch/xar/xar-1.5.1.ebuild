# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xar/xar-1.5.1.ebuild,v 1.1 2007/06/12 17:15:25 drac Exp $

EAPI="prefix"

DESCRIPTION="The XAR project aims to provide an easily extensible archive format."
HOMEPAGE="http://code.google.com/p/xar"
SRC_URI="http://xar.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

RDEPEND="virtual/libc"
DEPEND="${RDEPEND}
	dev-libs/openssl
	dev-libs/libxml2
	sys-libs/zlib"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
}
