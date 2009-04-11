# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ml/extlib/extlib-1.5.1.ebuild,v 1.4 2008/04/20 14:09:02 maekke Exp $

inherit findlib eutils

EAPI=1

DESCRIPTION="Standard library extensions for O'Caml"
HOMEPAGE="http://code.google.com/p/ocaml-extlib/"
SRC_URI="http://ocaml-extlib.googlecode.com/files/${P}.tar.gz"
LICENSE="LGPL-2.1"
DEPEND=">=dev-lang/ocaml-3.07"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc +ocamlopt"

pkg_setup() {
	if use ocamlopt && ! built_with_use --missing true dev-lang/ocaml ocamlopt; then
		eerror "In order to build ${PN} with native code support from ocaml"
		eerror "You first need to have a native code ocaml compiler."
		eerror "You need to install dev-lang/ocaml with ocamlopt useflag on."
		die "Please install ocaml with ocamlopt useflag"
	fi
}

src_compile() {
	emake all || die "failed to build"
	if use ocamlopt; then
		emake opt || die "failed to build"
	fi

	if use doc; then
		emake doc || die "failed to create documentation"
	fi
}

src_install () {
	findlib_src_install

	# install documentation
	dodoc README.txt

	if use doc; then
		dohtml doc/*
	fi
}
