# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/imake/imake-1.0.3.ebuild,v 1.1 2010/04/17 13:30:30 scarabeus Exp $

EAPI=3

XORG_STATIC=no
inherit xorg-2

DESCRIPTION="C preprocessor interface to the make utility"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-misc/xorg-cf-files"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# don't use Sun compilers on Solaris, we want GCC from prefix
	sed -i -e "1s/^.*$/#if defined(sun)\n# undef sun\n#endif/" \
		imake.c imakemdep.h
}
