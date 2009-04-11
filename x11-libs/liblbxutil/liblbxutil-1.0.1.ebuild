# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/liblbxutil/liblbxutil-1.0.1.ebuild,v 1.9 2009/01/10 03:52:53 miknix Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular toolchain-funcs

DESCRIPTION="X.Org lbxutil library"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xextproto"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	if tc-is-cross-compiler; then
		echo 'mkg3states_LINK = '"$(tc-getBUILD_CC)"' -o mkg3states' \
		     '$(srcdir)/image/mkg3states.c \#' >> \
		     src/Makefile.am || die "Cannot hack Makefile.am to x-compile."
	fi

	eautoreconf
}
