# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/regex-base/regex-base-0.72.0.1.ebuild,v 1.1 2007/12/20 02:38:55 dcoutts Exp $

EAPI="prefix"

CABAL_FEATURES="lib profile haddock"
CABAL_MIN_VERSION=1.2
inherit haskell-cabal

DESCRIPTION="Replaces/Enhances Text.Regex"
HOMEPAGE="http://sourceforge.net/projects/lazy-regex"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ghc-6.6"
