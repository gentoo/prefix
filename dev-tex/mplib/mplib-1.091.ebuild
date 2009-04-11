# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/mplib/mplib-1.091.ebuild,v 1.7 2008/10/05 19:51:16 jer Exp $

EAPI=1

inherit libtool

DESCRIPTION="New, revamped version of the MetaPost interpreter"
HOMEPAGE="http://foundry.supelec.fr/projects/metapost"
SRC_URI="http://foundry.supelec.fr/frs/download.php/670/${PN}-beta-${PV}-src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
# We enalbe lua by default because it will be needed by luatex
IUSE="doc +lua"

RDEPEND="virtual/tex-base
	lua? ( dev-lang/lua )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}-beta-${PV}/src/texk/web2c/mpdir

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

src_compile() {
	econf $(use_enable lua)
	# parallel make fails from time to time... needs to be fixed
	emake KPSESRCDIR="${EPREFIX}"/usr/include/kpathsea KPSELIB=-lkpathsea -j1 || die "failed to build mplib"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	mv "${ED}/usr/bin/mpost" "${ED}/usr/bin/mpost-${P}" || die "failed to rename mpost"
	dodoc "${WORKDIR}/${PN}-beta-${PV}/CHANGES"	"${WORKDIR}/${PN}-beta-${PV}/README"
	if use doc ; then
		insinto /usr/share/doc/${PF}
		doins "${WORKDIR}/${PN}-beta-${PV}/manual/"*.pdf
	fi
}
