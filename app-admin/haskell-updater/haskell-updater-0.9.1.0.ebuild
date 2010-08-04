# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/haskell-updater/haskell-updater-0.9.1.0.ebuild,v 1.5 2010/07/09 14:57:56 slyfox Exp $

CABAL_FEATURES="bin nocabaldep"
inherit haskell-cabal

DESCRIPTION="Rebuild Haskell dependencies in Gentoo"
HOMEPAGE="http://haskell.org/haskellwiki/Gentoo#haskell-updater"
SRC_URI="http://code.haskell.org/~kolmodin/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="=dev-lang/ghc-6.10*"

# Need a lower version for portage to get --keep-going
RDEPEND="|| ( >=sys-apps/portage-2.1.6
			  sys-apps/pkgcore
			  sys-apps/paludis )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '/pkgDBDir/s:"/:"'"${EPREFIX}"'/:' \
		Distribution/Gentoo/Packages.hs || die
}

src_compile() {
	CABAL_CONFIGURE_FLAGS="--bindir=${EPREFIX}/usr/sbin"

	cabal_src_compile
}

src_install() {
	cabal_src_install

	dodoc TODO
}
