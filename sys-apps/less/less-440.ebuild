# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/less/less-440.ebuild,v 1.1 2011/01/06 01:04:46 vapier Exp $

inherit eutils

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="unicode"

DEPEND=">=sys-libs/ncurses-5.2"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	cp "${DISTDIR}"/code2color "${S}"/
	epatch "${FILESDIR}"/code2color.patch
}

yesno() { use $1 && echo yes || echo no ; }
src_compile() {
	export ac_cv_lib_ncursesw_initscr=$(yesno unicode)
	export ac_cv_lib_ncurses_initscr=$(yesno !unicode)
	# Solaris includes regcmp in it's libc, but configure wrongly checks -lgen
	# and -lintl, which obviously both "provide" regcmp.
	if [[ ${CHOST} == *-solaris* ]] ; then
		export ac_cv_lib_gen_regcmp=no
		export ac_cv_lib_intl_regcmp=no
	fi
	econf || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	dobin code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe || die "newbin"
	dosym lesspipe /usr/bin/lesspipe.sh
	newenvd "${FILESDIR}"/less.envd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
