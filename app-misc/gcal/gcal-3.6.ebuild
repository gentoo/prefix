# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/gcal/gcal-3.6.ebuild,v 1.1 2010/06/07 08:21:55 jlec Exp $

EAPI="3"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="The GNU Calendar - a replacement for cal"
HOMEPAGE="http://www.gnu.org/software/gcal/gcal.html"
SRC_URI="mirror://gnu/gcal/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="ncurses nls"

DEPEND="nls? ( >=sys-devel/gettext-0.17 )"
RDEPEND=""

src_configure() {
	# i'm really out of ideas here...
#	if [[ ${CHOST} == *-interix* ]]; then
#		use nls && append-ldflags -lintl
#	fi

	tc-export CC
	append-flags -D_GNU_SOURCE
	econf \
		--disable-rpath \
		$(use_enable nls) \
		$(use_enable ncurses term)
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc BUGS LIMITATIONS NEWS README THANKS TODO || die
}
