# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xbindkeys/xbindkeys-1.8.0.ebuild,v 1.3 2007/03/14 01:18:50 troll Exp $

EAPI="prefix"

inherit eutils

IUSE="guile tk"

DESCRIPTION="Tool for launching commands on keystrokes"
SRC_URI="http://hocwp.free.fr/xbindkeys/${P}.tar.gz"
HOMEPAGE="http://hocwp.free.fr/xbindkeys/"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86"
SLOT="0"

IUSE="guile tk"

RDEPEND="|| ( x11-libs/libX11 virtual/x11 )
	guile? ( dev-scheme/guile )
	tk? ( dev-lang/tk )"

DEPEND="${RDEPEND}
	|| ( x11-proto/xproto virtual/x11 )"

pkg_setup() {
	if use guile && has_version ">=dev-scheme/guile-1.8" \
		&& ! built_with_use ">=dev-scheme/guile-1.8" deprecated
	then
		eerror "In order to compile xbindkeys with guile-1.8 or higher, you need"
		eerror "to recompile dev-scheme/guile with the \"deprecated\" USE flag."
		die "Please re-emerge dev-scheme/guile with USE=\"deprecated\"."
	fi
}

src_compile() {
	local myconf
	use tk || myconf="${myconf} --disable-tk"
	use guile || myconf="${myconf} --disable-guile"

	econf ${myconf} || die "configure failed"
	emake DESTDIR=${D} || die "make failed"
}

src_install() {
	make DESTDIR=${D} BINDIR="${EPREFIX}"/usr/bin install || die "make install failed"
}
