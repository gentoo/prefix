# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unace/unace-2.5-r1.ebuild,v 1.6 2008/04/15 15:13:09 vapier Exp $

inherit eutils toolchain-funcs

DEB_VER="5"
DESCRIPTION="ACE unarchiver"
HOMEPAGE="http://www.winace.com/"
SRC_URI="mirror://debian/pool/non-free/u/unace-nonfree/unace-nonfree_${PV}.orig.tar.gz
	mirror://debian/pool/non-free/u/unace-nonfree/unace-nonfree_${PV}-${DEB_VER}.diff.gz"

LICENSE="freedist"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/unace-nonfree_${PV}-${DEB_VER}.diff
	local p
	for p in $(<unace-nonfree-${PV}/debian/patches/00list) ; do
		epatch unace-nonfree-${PV}/debian/patches/${p}.dpatch
	done
	tc-export CC
}

src_install() {
	dobin unace || die
	doman unace-nonfree-${PV}/debian/manpage/unace.1
}
