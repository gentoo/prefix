# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/scm/scm-5.5.4.ebuild,v 1.3 2008/11/17 13:40:07 pchrist Exp $

inherit versionator eutils

#version magic thanks to masterdriverz and UberLord using bash array instead of tr
trarr="0abcdefghi"
MY_PV="$(get_version_component_range 1)${trarr:$(get_version_component_range 2):1}$(get_version_component_range 3)"

MY_P=${PN}${MY_PV}
S=${WORKDIR}/${PN}
DESCRIPTION="Scheme implementation from author of slib"
SRC_URI="http://swiss.csail.mit.edu/ftpdir/scm/${MY_P}.zip"

HOMEPAGE="http://swiss.csail.mit.edu/~jaffer/SCM"

SLOT="0"
LICENSE="GPL-2-with-linking-exception"
KEYWORDS="~amd64-linux ~x86-macos"
IUSE=""

#unzip for unpacking
RDEPEND=""
DEPEND="app-arch/unzip
		>=dev-scheme/slib-3.1.5"

src_unpack() {
	unpack ${A}; cd "${S}"

#	cp Makefile Makefile.old

	sed "s#local/##" -i Makefile

	#sent upstream again
	sed "s#mkdir#mkdir -p#" -i Makefile
	sed "s#-p -p#-p#" -i Makefile
	sed -i -e 's/mandir = $(prefix)man\//mandir = $(prefix)share\/man\//' Makefile

#	diff -u Makefile.old Makefile
}

src_compile() {
	einfo "Making scmlit"
	#parallel make fails sometimes
	emake -j1 scmlit
	einfo "Creating script to build scm"
	echo "srcdir=${EPREFIX}/usr/share/scm/" > srcdir.mk
	./build --compiler-options="${CFLAGS}" --linker-options="${LDFLAGS}" -F macro -F inexact &> _compile.sh || die
	einfo "Building scm"
	sh _compile.sh || die
}

src_install() {
	emake DESTDIR="${D}" install
}

pkg_postinst() {
	[ "${ROOT}" == "/" ] && pkg_config
}

pkg_config() {
	einfo "Regenerating catalog..."
	scm -e "(require 'new-catalog)"
}
