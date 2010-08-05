# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haddock/haddock-0.9.ebuild,v 1.3 2010/07/01 19:24:02 jer Exp $

CABAL_FEATURES="bin"
inherit haskell-cabal eutils autotools prefix

DESCRIPTION="A documentation tool for Haskell."
HOMEPAGE="http://haskell.org/haddock/"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

DEPEND="<dev-lang/ghc-6.10
		>=dev-haskell/cabal-1.2
	doc? (  ~app-text/docbook-xml-dtd-4.2
			app-text/docbook-xsl-stylesheets
			>=dev-libs/libxslt-1.1.2 )"
RDEPEND=""

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
		dohtml -r "${S}/doc/haddock/"* || die "installing docs failed"
	fi
	dodoc CHANGES README
}
