# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/cabal/cabal-1.1.6.2.ebuild,v 1.9 2007/10/31 12:54:22 dcoutts Exp $

EAPI="prefix"

CABAL_FEATURES="bootstrap profile lib"
inherit haskell-cabal eutils

DESCRIPTION="Haskell Common Architecture for Building Applications and Libraries"
HOMEPAGE="http://haskell.org/cabal"
SRC_URI="http://haskell.org/cabal/release/${P}/${P}.tar.gz"
LICENSE="as-is"
SLOT="0"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"

IUSE="doc"

DEPEND=">=dev-lang/ghc-6.2"

GHC_PV="6.6.1"

src_unpack() {
	if test $(ghc-version) = ${GHC_PV}; then
	    elog "cabal-${PV} is included in ghc-${GHC_PV}, nothing to install."
	else
		unpack "${A}"
		if ! $(ghc-cabal); then
			sed -i 's/Build-Depends: base/Build-Depends: base, unix/' \
				${S}/Cabal.cabal
		fi
	fi
}

src_compile() {
	if ! test $(ghc-version) = ${GHC_PV}; then
		if ghc-cabal; then
			make setup HC="$(ghc-getghc) -ignore-package Cabal"
		else
			make setup HC="$(ghc-getghc)"
		fi
		cabal-configure
		cabal-build
	fi
}

src_install() {
	if test $(ghc-version) = ${GHC_PV}; then
		t=$(ghc-confdir)
		dodir "${t#${EPREFIX}}"
		echo '[]' > "${D}/$(ghc-confdir)/$(ghc-localpkgconf)"
	else
		cabal_src_install

		# documentation (install directly)
		dohtml -r doc/users-guide
		if use doc; then
			dohtml -r doc/API
			dohtml -r doc/pkg-spec-html
			dodoc doc/pkg-spec.pdf
		fi
		dodoc changelog copyright README releaseNotes TODO
	fi
}
