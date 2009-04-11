# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/scm/scm-5.5.5-r1.ebuild,v 1.1 2009/02/03 16:34:28 hkbst Exp $

inherit versionator eutils

#version magic thanks to masterdriverz and UberLord using bash array instead of tr
trarr="0abcdefghi"
MY_PV="$(get_version_component_range 1)${trarr:$(get_version_component_range 2):1}$(get_version_component_range 3)"

MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${PN}
DESCRIPTION="Scheme implementation from author of slib"
SRC_URI="http://swiss.csail.mit.edu/ftpdir/scm/${MY_P}.zip"
HOMEPAGE="http://swiss.csail.mit.edu/~jaffer/SCM"

SLOT="0"
LICENSE="LGPL-3"
KEYWORDS="~amd64-linux ~x86-macos"
IUSE=""

#unzip for unpacking
RDEPEND=""
DEPEND="app-arch/unzip
		>=dev-scheme/slib-3.1.5"

src_unpack() {
	unpack ${A}; cd "${S}"

	cp Makefile Makefile.old

	sed "s#local/##" -i Makefile
	sed 's:man1dir = $(prefix)man/man1/:man1dir = $(prefix)share/man/man1/:' -i Makefile # bug 247182

	diff -u Makefile.old Makefile
}

src_compile() {
	einfo "Making scmlit"
	#parallel make fails sometimes
	emake -j1 scmlit || die
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
