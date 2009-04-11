# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/gambit/gambit-4.4.0.ebuild,v 1.4 2009/01/28 16:46:59 hkbst Exp $

inherit eutils elisp-common check-reqs multilib

MY_PN=gambc
MY_PV=${PV//./_}
MY_P=${MY_PN}-v${MY_PV}

DESCRIPTION="Gambit-C is a native Scheme to C compiler and interpreter."
HOMEPAGE="http://www.iro.umontreal.ca/~gambit/"
SRC_URI="http://www.iro.umontreal.ca/~gambit/download/gambit/v${PV%.*}/source/${MY_P}.tgz"

LICENSE="|| ( Apache-2.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="emacs? ( virtual/emacs )"
RDEPEND=""

SITEFILE="50gambit-gentoo.el"

S=${WORKDIR}/${MY_P} #-devel

IUSE="emacs static"

_pkg_setup() {
	if use big-iron; then
		ewarn "compiling each Scheme module as a single C function"
		ewarn "using gcc specific optimizations"
		ewarn "approximately 2GB ram will be needed instead of 0.5GB"
		ewarn "this will cause heavy thrashing of your system"
		ewarn "and may cause your compiler to crash when it runs out of memory"
		ewarn "unless your system is BIG IRON"
		# need this much memory in MBytes (does *not* check swap)
		CHECKREQS_MEMORY="2560"	check_reqs
	else
		ewarn "NOT compiling each Scheme module as a single C function"
		ewarn "NOT using gcc specific optimizations"
		ewarn "approximately 0.5GB ram will be needed"
		ewarn "if you experience thrashing, try disabling parallel building or setting -O1"
		# need this much memory in MBytes (does *not* check swap)
		CHECKREQS_MEMORY="768" check_reqs
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-install_name.patch
	eautoreconf
}

src_compile() {
	econf $(use_enable !static shared) --enable-single-host --disable-absolute-shared-libs

	emake bootstrap || die

	if use emacs; then
		elisp-compile misc/*.el || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	# rename the /usr/bin/gsc to avoid collision with gsc from ghostscript
	mv "${ED}"/usr/bin/gsc "${ED}"/usr/bin/gsc-gambit
}

_src_install(){
	rm "${ED}"/usr/current

	mv "${ED}"/usr/syntax-case.scm "${ED}"/usr/$(get_libdir)

	# remove emacs/site-lisp/gambit.el
	rm -r "${ED}"/usr/share/emacs
	if use emacs; then
		elisp-install ${PN} misc/*.{el,elc}
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
	fi

	dodoc INSTALL.txt README
	insinto /usr/share/doc/${PF}
	doins -r examples

	# create some more explicit names
	dosym gsc-gambit usr/bin/gambit-compiler
	dosym gsi usr/bin/gambit-interpreter

	echo "GAMBCOPT=\"=/usr/\"" > "${T}"/50gambit && doenvd "${T}"/50gambit
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
