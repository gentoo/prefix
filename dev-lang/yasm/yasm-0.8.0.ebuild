# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/yasm/yasm-0.8.0.ebuild,v 1.3 2009/06/10 19:50:34 maekke Exp $

EAPI="2"

DESCRIPTION="Assembler that supports amd64"
HOMEPAGE="http://www.tortall.net/projects/yasm/"
SRC_URI="http://www.tortall.net/projects/yasm/releases/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS
}
