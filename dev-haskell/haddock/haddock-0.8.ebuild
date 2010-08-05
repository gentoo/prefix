# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haddock/haddock-0.8.ebuild,v 1.17 2010/07/01 19:24:02 jer Exp $

CABAL_FEATURES="bin"
inherit haskell-cabal eutils versionator autotools prefix

MY_PF=$(replace_version_separator 3 '-' ${PF})

DESCRIPTION="A documentation tool for Haskell."
HOMEPAGE="http://haskell.org/haddock/"
SRC_URI="http://haskell.org/haddock/${MY_PF}-src.tar.gz"
LICENSE="as-is"
SLOT="0"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

IUSE="doc"

DEPEND="<dev-lang/ghc-6.10
		>=dev-haskell/cabal-1.1.4
	doc? (  ~app-text/docbook-xml-dtd-4.2
			app-text/docbook-xsl-stylesheets
			>=dev-libs/libxslt-1.1.2 )"
RDEPEND=""

S="${WORKDIR}/${MY_PF}"

src_unpack () {
	unpack ${A}

	#FIXME: remove the following two workarounds when haddock-0.9 is released

	# Cabal 1.2 expects the pre-processed sources in a different location:
	mkdir -p "${S}/dist/build/haddock/haddock-tmp/"
	cp  "${S}/src/HaddockLex.hs" \
		"${S}/src/HaddockParse.hs" \
		"${S}/src/HsParser.hs" \
		"${S}/dist/build/haddock/haddock-tmp/"

	# Add in the extra split-base deps
	if version_is_at_least "6.8" "$(ghc-version)"; then
		sed -i -e '/build-depends:/a \
			,array, containers, directory, pretty, process' \
			"${S}/haddock.cabal"
	fi
}

src_compile () {
	cabal_src_compile
	if use doc; then
		cd "${S}/doc"
		epatch "${FILESDIR}"/${P}-prefix.patch
		eprefixify configure.ac
		eautoreconf
		./configure --prefix="${ED}/usr/" \
			|| die 'error configuring documentation.'
		make html || die 'error building documentation.'
	fi
}

src_install () {
	cabal_src_install
	if use doc; then
		dohtml -r "${S}/doc/haddock/"*
	fi
	dodoc CHANGES README
}
