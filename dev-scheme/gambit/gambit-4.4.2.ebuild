# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/gambit/gambit-4.4.2.ebuild,v 1.1 2009/03/16 21:14:49 hkbst Exp $

inherit eutils elisp-common autotools

MY_PN=gambc
MY_PV=${PV//./_}
MY_P=${MY_PN}-v${MY_PV}

DESCRIPTION="Gambit-C is a native Scheme to C compiler and interpreter."
HOMEPAGE="http://www.iro.umontreal.ca/~gambit/"
SRC_URI="http://www.iro.umontreal.ca/~gambit/download/gambit/v${PV%.*}/source/${MY_P}.tgz"

LICENSE="|| ( Apache-2.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

#gsc is now Gambit Scheme Compile and not ghostscript.
#only app-text/ghostscript-gpl-8.64 has freed gsc yet.
DEPEND="emacs? ( virtual/emacs )
		!app-text/ghostscript-esp
		!app-text/ghostscript-gnu
		!<app-text/ghostscript-gpl-8.64"
RDEPEND=""

SITEFILE="50gambit-gentoo.el"

S=${WORKDIR}/${MY_P} #-devel

IUSE="emacs static"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-4.4.0-install_name.patch
	eautoreconf
}

src_compile() {
	econf $(use_enable !static shared) --docdir="${EPREFIX}"/usr/share/doc/${PF} --enable-single-host --disable-absolute-shared-libs

	emake bootstrap || die

	if use emacs; then
		elisp-compile misc/*.el || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
