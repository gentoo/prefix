# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfont/libXfont-1.4.2.ebuild,v 1.5 2010/07/22 16:17:07 maekke Exp $

EAPI=3
inherit xorg-2 flag-o-matic

DESCRIPTION="X.Org Xfont library"

KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6"

RDEPEND="x11-libs/xtrans
	x11-libs/libfontenc
	x11-proto/xproto
	x11-proto/fontsproto
	x11-proto/fontcacheproto
	>=media-libs/freetype-2
	app-arch/bzip2"
DEPEND="${RDEPEND}"

pkg_setup() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable ipv6)
		--with-bzip2
		--disable-devel-docs
		--with-encodingsdir=${EPREFIX}/usr/share/fonts/encodings"

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

	if [[ ${CHOST} == *-winnt* ]]; then
		# windows uses stdcall here, resulting in different
		# symbol names for the linker. thus the configure check
		# fails (it wouldn't if it would include the correct
		# header file, of course)
		export ac_cv_lib_bz2_BZ2_bzopen=yes
	fi

	x-modular_src_compile
}
