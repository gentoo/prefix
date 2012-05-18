# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/hunit/hunit-1.2.0.3.ebuild,v 1.8 2011/02/25 13:17:03 xarthisius Exp $

CABAL_FEATURES="lib profile haddock"
inherit base haskell-cabal

MY_PN="HUnit"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A unit testing framework for Haskell"
HOMEPAGE="http://hunit.sourceforge.net/"
SRC_URI="http://hackage.haskell.org/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ghc-6.6.1
		>=dev-haskell/cabal-1.2"

RDEPEND=">=dev-lang/ghc-6.6.1"

S="${WORKDIR}/${MY_P}"

src_install () {
	cabal_src_install
	if use doc; then
		dohtml -r "${S}/doc/"*
	fi
}
