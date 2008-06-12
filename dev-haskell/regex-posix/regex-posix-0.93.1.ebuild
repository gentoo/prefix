# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/regex-posix/regex-posix-0.93.1.ebuild,v 1.1 2008/05/04 12:31:11 kolmodin Exp $

EAPI="prefix"

CABAL_FEATURES="profile haddock lib"
inherit haskell-cabal

DESCRIPTION="The posix regex backend for regex-base"
HOMEPAGE="http://sourceforge.net/projects/lazy-regex"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ghc-6.6
		>=dev-haskell/cabal-1.2
		>=dev-haskell/regex-base-0.93"
