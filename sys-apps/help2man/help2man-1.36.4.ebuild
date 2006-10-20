# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/help2man/help2man-1.36.4.ebuild,v 1.11 2006/10/17 09:41:34 uberlord Exp $

EAPI="prefix"

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="http://www.gnu.org/software/help2man"
SRC_URI="http://ftp.gnu.org/gnu/help2man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	nls? ( dev-perl/Locale-gettext
		>=sys-devel/gettext-0.12.1-r1 )"

src_unpack() {
	unpack ${A}
	cd ${S}
	use userland_Darwin && sed -i \
		-e 's|-fPIC -shared|-dynamiclib|g' \
		Makefile.in
}

src_compile() {
	econf $(use_enable nls) || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed"
	dodoc ChangeLog NEWS README THANKS
}
