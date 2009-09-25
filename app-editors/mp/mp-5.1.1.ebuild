# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mp/mp-5.1.1.ebuild,v 1.2 2009/09/23 15:23:22 patrick Exp $

inherit eutils

DESCRIPTION="Minimum Profit: A text editor for programmers"
HOMEPAGE="http://www.triptico.com/software/mp.html"
SRC_URI="http://www.triptico.com/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="gtk ncurses nls pcre iconv"

RDEPEND="ncurses? ( sys-libs/ncurses )
	gtk? ( >=x11-libs/gtk+-2 >=x11-libs/pango-1.8.0 )
	!gtk? ( sys-libs/ncurses )
	nls? ( sys-devel/gettext )
	pcre? ( dev-libs/libpcre )
	iconv? ( virtual/libiconv )
	app-text/grutatxt"
DEPEND="${RDEPEND}
	app-text/grutatxt
	dev-util/pkgconfig
	dev-lang/perl"

src_compile() {
	local myconf="--prefix=${EPREFIX}/usr --without-win32"

	if use gtk; then
		! use ncurses && myconf="${myconf} --without-curses"
	else
		myconf="${myconf} --without-gtk2"
	fi

	use nls || myconfig="${myconf} --without-gettext"

	if use pcre; then
		myconf="${myconf} --with-pcre"
	else
		myconf="${myconf} --without-pcre --with-included-regex"
	fi

	use iconv || myconf="${myconf} --without-iconv"

	sh config.sh ${myconf} || die "Configure failed"

	echo ${CFLAGS} >> config.cflags
	echo ${LDFLAGS} >> config.ldflags
	emake || die "Compile Failed"
}

src_install() {
	mkdir -p "${ED}/${DESTTREE}/bin"
	sh config.sh --prefix="${EPREFIX}${DESTTREE}"
	make DESTDIR="${D}" install || die "Install Failed"
	use gtk && dosym mp-5 ${DESTTREE}/bin/gmp
}

pkg_postinst() {
	if use gtk ; then
		einfo
		einfo "mp-5 is symlinked to gmp! Use"
		einfo "$ DISPLAY=\"\" mp-5"
		einfo "to use text mode!"
		einfo
		epause 5
	fi
}
