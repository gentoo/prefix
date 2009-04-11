# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboop/liboop-1.0.ebuild,v 1.12 2009/03/09 02:31:55 vapier Exp $

inherit flag-o-matic

DESCRIPTION="low-level event loop management library for POSIX-based operating systems"
HOMEPAGE="http://liboop.ofb.net/"
SRC_URI="http://download.ofb.net/liboop/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="adns gnome tcl readline libwww"

DEPEND="adns? ( net-libs/adns )
	gnome? ( dev-libs/glib )
	tcl? ( dev-lang/tcl )
	readline? ( sys-libs/readline )
	libwww? ( net-libs/libwww )"

src_compile() {
	export ac_cv_path_PROG_LDCONFIG=true
	econf \
		$(use_with adns) \
		$(use_with gnome) \
		$(use_with tcl tcltk) \
		$(use_with readline) \
		$(use_with libwww) \
		|| die
	emake -j1 || die
}

src_install() {
	emake install DESTDIR="${D}" || die
}
