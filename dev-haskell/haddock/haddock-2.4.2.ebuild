# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haddock/haddock-2.4.2.ebuild,v 1.2 2009/04/20 00:08:07 mr_bones_ Exp $

CABAL_FEATURES="bin lib"
# don't enable profiling as the 'ghc' package is not built with profiling
inherit haskell-cabal autotools eutils prefix

DESCRIPTION="A documentation-generation tool for Haskell libraries"
HOMEPAGE="http://www.haskell.org/haddock/"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

RDEPEND="~dev-lang/ghc-6.10.2
		dev-haskell/filepath
		dev-haskell/ghc-paths"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6
		doc? (  ~app-text/docbook-xml-dtd-4.2
				app-text/docbook-xsl-stylesheets
				>=dev-libs/libxslt-1.1.2 )"

src_unpack() {
	unpack ${A}

	if use doc; then
		cd "${S}/doc"
		epatch "${FILESDIR}"/${PN}-0.8-prefix.patch
		eprefixify configure.ac
		eautoreconf
	fi

}

src_compile () {
	cabal_src_compile
	if use doc; then
		cd "${S}/doc"
		./configure --prefix="${ED}/usr/" \
			|| die 'error configuring documentation.'
		emake html || die 'error building documentation.'
	fi
}

src_install () {
	cabal_src_install
	if use doc; then
		dohtml -r "${S}/doc/haddock/"*
	fi
	dodoc CHANGES README
}
