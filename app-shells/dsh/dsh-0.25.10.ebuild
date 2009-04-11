# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/dsh/dsh-0.25.10.ebuild,v 1.5 2008/05/12 16:18:13 maekke Exp $

DESCRIPTION="Distributed Shell"
HOMEPAGE="http://www.netfort.gr.jp/~dancer/software/dsh.html.en"
SRC_URI="http://www.netfort.gr.jp/~dancer/software/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls"

DEPEND="dev-libs/libdshconfig"
RDEPEND="${DEPEND}
	virtual/ssh"

src_compile() {
	econf --sysconfdir="${EPREFIX}"/etc/dsh $(use_enable nls) || die "econf failed."
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodir /etc/dsh/group
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
