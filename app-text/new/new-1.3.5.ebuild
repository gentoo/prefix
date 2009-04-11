# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/new/new-1.3.5.ebuild,v 1.6 2008/05/05 19:35:47 drac Exp $

DESCRIPTION="template system useful when used with a simple text editor (like vi)"
HOMEPAGE="http://www.flyn.org/"
SRC_URI="http://www.flyn.org/projects/new/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	# stack_t is in the system headers on at least Darwin
	sed -i -e 's/stack_t/flyn_stack_t/g' src/fmt_ptrn.c
}

RDEPEND=">=dev-libs/glib-2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README TODO
}
