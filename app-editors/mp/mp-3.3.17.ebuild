# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mp/mp-3.3.17.ebuild,v 1.9 2007/02/09 22:01:18 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Minimum Profit: A text editor for programmers"
HOMEPAGE="http://www.triptico.com/software/mp.html"
SRC_URI="http://www.triptico.com/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="gtk ncurses nls pcre"

RDEPEND="virtual/libc
		ncurses? ( sys-libs/ncurses )
		gtk? ( >=x11-libs/gtk+-2 >=x11-libs/pango-1.8.0 )
		!gtk? ( sys-libs/ncurses )
		nls? ( sys-devel/gettext )
		pcre? ( dev-libs/libpcre )
		 dev-lang/perl"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"

src_compile() {
	local myconf="--prefix=${EPREFIX}/usr --without-win32 --without-gtk1"

	if use gtk ; then
		! use ncurses && myconf="${myconf} --without-curses"
	else
		myconf="${myconf} --without-gtk2"
	fi

	use nls || myconfig="${myconf} --without-i18n --without-gettext"
	use pcre || myconf="${myconf} --without-pcre --with-included-regex"

	sh config.sh ${myconf} || die "Configure failed"

	echo ${CFLAGS} >> config.cflags
	echo ${LDFLAGS} >> config.ldflags

	emake || die "Compile Failed"
}

src_install() {
	dobin mp || die "Install Failed"

	use gtk && dosym mp ${DESTTREE}/bin/gmp

	dodoc AUTHORS README Changelog mprc.sample
	doman mp.1
}

pkg_postinst() {
	if use gtk ; then
		einfo
		einfo "mp is symlinked to gmp! Use mp -tx to use text mode!"
		einfo
		epause 5
	fi
}
