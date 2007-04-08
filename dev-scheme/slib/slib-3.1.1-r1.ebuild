# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/slib/slib-3.1.1-r1.ebuild,v 1.9 2007/04/04 19:32:03 wolf31o2 Exp $

EAPI="prefix"

inherit versionator eutils

#version magic thanks to masterdriverz and UberLord using bash array instead of tr
trarr="0abcdefghi"
MY_PV="$(get_version_component_range 1)${trarr:$(get_version_component_range 2):1}$(get_version_component_range 3)"

MY_P=${PN}${MY_PV}
S=${WORKDIR}/${PN}
DESCRIPTION="library providing functions for Scheme implementations"
SRC_URI="http://swiss.csail.mit.edu/ftpdir/scm/OLD/${MY_P}.zip"

HOMEPAGE="http://swiss.csail.mit.edu/~jaffer/SLIB"

SLOT="0"
LICENSE="public-domain BSD"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

#unzip for unpacking
#depend on guile for now, until slib actually works with another scheme implementation in portage
RDEPEND="dev-scheme/guile"
DEPEND="app-arch/unzip
	${RDEPEND}"

# slib tests rely on scm being installed. It isn't even in portage :(
RESTRICT="test"

# maybe also do "make infoz"

src_install() {
	insinto /usr/share/slib/ #don't install directly into guile dir
	doins *.scm
	doins *.init
	dodoc ANNOUNCE ChangeLog FAQ README
	doinfo slib.info
	dosym /usr/share/slib/ /usr/share/guile/slib # link from guile dir
}

pkg_postinst() {
	if [ "${EROOT}" == "/" ] ; then
		einfo "Installing..."
		guile -c "(use-modules (ice-9 slib)) (require 'new-catalog)" "/"
	fi
}
