# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.13.ebuild,v 1.11 2009/03/17 10:17:02 armin76 Exp $

inherit flag-o-matic

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND="!=app-text/tetex-2*
	>=sys-libs/ncurses-5.2-r2
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	app-arch/lzma-utils
	nls? ( sys-devel/gettext )
	sys-apps/help2man"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-4.11-prefix.patch
	epatch "${FILESDIR}"/${P}-mint.patch
}

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die

	# Make cross-compiler safe (#196041)
	if tc-is-cross-compiler; then
		emake -C tools/gnulib/lib || die "emake -C tools/gnulib/lib"
	fi

	emake || die "emake"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
	newdoc info/README README.info
	newdoc makeinfo/README README.makeinfo

	rm -f "${ED}"/usr/lib/charset.alias #195148
}
