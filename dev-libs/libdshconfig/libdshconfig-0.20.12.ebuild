# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdshconfig/libdshconfig-0.20.12.ebuild,v 1.3 2008/05/12 16:17:09 maekke Exp $

DESCRIPTION="Library for parsing dsh.style configuration files"
HOMEPAGE="http://www.netfort.gr.jp/~dancer/software/downloads/"
SRC_URI="http://www.netfort.gr.jp/~dancer/software/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

DEPEND="virtual/libc"
RDEPEND="virtual/ssh"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog
}
