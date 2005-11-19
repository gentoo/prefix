# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/less/less-385_p4-r2.ebuild,v 1.2 2005/10/20 04:59:27 vapier Exp $

EAPI="prefix"

inherit eutils

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
PATCH_VER=${PV/_p/-cl}
DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/ https://gna.org/forum/forum.php?forum_id=715"
SRC_URI="http://www.greenwoodsoftware.com/less/${MY_P}.tar.gz
	http://download.gna.org/hpr/less/${MY_PV}/${PATCH_VER}/less-${PATCH_VER}.patch.bz2
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="unicode"

DEPEND=">=sys-libs/ncurses-5.2"
PROVIDE="virtual/pager"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz
	cd "${S}"
	epatch "${DISTDIR}"/less-${PATCH_VER}.patch.bz2
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

	dodoc NEWS README*
}
