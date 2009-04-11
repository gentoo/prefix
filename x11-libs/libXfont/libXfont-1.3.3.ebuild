# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfont/libXfont-1.3.3.ebuild,v 1.1 2008/07/05 06:26:38 dberkholz Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xfont library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ipv6"

RDEPEND="x11-libs/xtrans
	x11-libs/libfontenc
	x11-proto/xproto
	x11-proto/fontsproto
	>=media-libs/freetype-2"
DEPEND="${RDEPEND}
	x11-proto/fontcacheproto"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	--with-encodingsdir=/usr/share/fonts/encodings"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_poll=no
		export ac_cv_header_poll_h=no
	fi

	x-modular_src_compile
}
