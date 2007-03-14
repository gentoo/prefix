# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/less/less-394.ebuild,v 1.14 2007/03/10 22:24:08 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRC_URI="http://www.greenwoodsoftware.com/less/${P}.tar.gz
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="|| ( GPL-2 less )"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="unicode"

DEPEND=">=sys-libs/ncurses-5.2"
PROVIDE="virtual/pager"

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
	econf || die
	emake || die
}

src_install() {
	dobin less lessecho lesskey code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe.sh || die "newbin"

	# the -R is Needed for groff-1.18 and later ...
	echo 'LESS="-R -M --shift 5"' > 70less
	doenvd 70less

	for m in *.nro ; do
		newman ${m} ${m/nro/1}
	done

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo
}
