# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.7.ebuild,v 1.11 2009/05/05 07:11:37 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xpm library"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	sys-devel/gettext
	x11-proto/xproto"

src_unpack() {
	PATCHES="${FILESDIR}"/${P}-winnt.patch
	x-modular_src_unpack
}

src_compile() {
	# the gettext configure check and code in sxpm are incorrect; they assume
	# gettext being in libintl, whereas Solaris has gettext by default
	# resulting in libintl not being added to LIBS
	[[ ${CHOST} == *-solaris* ]] && append-libs -lintl
	x-modular_src_compile
}
