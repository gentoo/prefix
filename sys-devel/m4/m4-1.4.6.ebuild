# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.6.ebuild,v 1.10 2006/11/03 18:46:17 grobian Exp $

EAPI="prefix"

#inherit toolchain-funcs

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	ftp://ftp.seindal.dk/gnu/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_compile() {
	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && [[ ${PREFIX/\//} != "" ]] && myconf="--program-prefix=g"
	econf \
		$(use_enable nls) \
		--enable-changeword \
		${myconf} \
		|| die
	emake || die #AR="$(tc-getAR)" || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
}
