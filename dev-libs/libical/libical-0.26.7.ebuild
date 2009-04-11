# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libical/libical-0.26.7.ebuild,v 1.9 2007/10/06 04:53:20 tgall Exp $

inherit versionator

MY_VER=$(replace_version_separator 2 -)

DESCRIPTION="libical is an implementation of basic iCAL protocols"
HOMEPAGE="http://www.aurore.net/projects/libical/"
SRC_URI="http://www.aurore.net/projects/libical/${PN}-${MY_VER}.aurore.tar.bz2"
SLOT="0"
LICENSE="|| ( MPL-1.1 LGPL-2 )"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/bison-1.875d
	>=sys-devel/flex-2.5.4a-r6
	>=sys-apps/gawk-3.1.4-r4
	>=dev-lang/perl-5.8.7-r3"

S="${WORKDIR}"/libical-${PV%.*}

src_compile() {
	# Fix 66377
	LDFLAGS="${LDFLAGS} -lpthread" econf || die "Configuration failed"
	emake || die "Compilation failed"
}

src_install () {
	einstall || die "Installation failed..."
}
