# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.8.ebuild,v 1.2 2006/11/27 00:27:57 vapier Exp $

EAPI="prefix"

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	ftp://ftp.seindal.dk/gnu/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

# remember: cannot dep on autoconf since it needs us
DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_compile() {
	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && [[ ${PREFIX/\//} != "" ]] && \
		myconf="--program-prefix=g"
	econf \
		$(use_enable nls) \
		--enable-changeword \
		${myconf} \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	# autoconf-2.60 for instance, first checks gm4, then m4.  If we don't have
	# gm4, it might find gm4 from outside the prefix on for instance Darwin
	[[ ${USERLAND} != "GNU" ]] && [[ ${PREFIX/\//} != "" ]] || \
		dosym /usr/bin/m4 /usr/bin/gm4
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
}
