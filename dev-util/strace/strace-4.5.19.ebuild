# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/strace/strace-4.5.19.ebuild,v 1.2 2009/10/28 13:59:07 jer Exp $

inherit flag-o-matic

DESCRIPTION="A useful diagnostic, instructional, and debugging tool"
HOMEPAGE="http://sourceforge.net/projects/strace/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="static aio"

DEPEND="aio? ( >=dev-libs/libaio-0.3.106 )"

src_compile() {
	filter-lfs-flags

	use static && append-ldflags -static

	econf $(use_enable aio libaio) || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog CREDITS NEWS PORTING README* TODO
}
