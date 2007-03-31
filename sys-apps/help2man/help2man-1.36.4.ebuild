# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/help2man/help2man-1.36.4.ebuild,v 1.12 2007/02/20 19:51:42 eroyf Exp $

EAPI="prefix"

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="http://www.gnu.org/software/help2man"
SRC_URI="http://ftp.gnu.org/gnu/help2man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
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
	use userland_Solaris && use nls \
		&& elog "nls support is broken on Solaris for this package, disabling"
	if use userland_Solaris ; then
		econf --disable-nls || die
	else
		econf $(use_enable nls) || die
	fi
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog NEWS README THANKS
}
