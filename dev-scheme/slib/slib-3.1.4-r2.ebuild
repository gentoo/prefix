# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/slib/slib-3.1.4-r2.ebuild,v 1.4 2007/05/30 20:34:56 mr_bones_ Exp $

EAPI="prefix"

inherit versionator eutils

#version magic thanks to masterdriverz and UberLord using bash array instead of tr
trarr="0abcdefghi"
MY_PV="$(get_version_component_range 1)${trarr:$(get_version_component_range 2):1}$(get_version_component_range 3)"

MY_P=${PN}${MY_PV}
S=${WORKDIR}/${PN}
DESCRIPTION="library providing functions for Scheme implementations"
SRC_URI="http://swiss.csail.mit.edu/ftpdir/scm/${MY_P}.zip"

HOMEPAGE="http://swiss.csail.mit.edu/~jaffer/SLIB"

SLOT="0"
LICENSE="public-domain BSD"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="" #test"

#unzip for unpacking
RDEPEND=""
DEPEND="app-arch/unzip"
#		test? ( dev-scheme/scm )"

IMPLEMENTATIONS="guile"

src_compile() {
	mkdir installers
	cd installers

	guile_install_command="guile -c \"(use-modules (ice-9 slib)) (require 'new-catalog)\""
#	gauche_install_command="gosh -e \"(require 'new-catalog)\""

	for impl in ${IMPLEMENTATIONS}; do
		command_var=${impl}_install_command
		make_installer ${impl} "${!command_var}"
	done
}

# maybe also do "make infoz"
src_install() {
	INSTALL_DIR="/usr/share/slib/"

	insinto ${INSTALL_DIR} #don't install directly into guile dir
	doins *.scm
	doins *.init
	dodoc ANNOUNCE ChangeLog FAQ README
	doinfo slib.info
	dosym ${INSTALL_DIR} /usr/share/guile/slib # link from guile dir
	dosym ${INSTALL_DIR} /usr/lib/slib
	dodir /etc/env.d/ && echo "SCHEME_LIBRARY_PATH=\"${EPREFIX}${INSTALL_DIR}\"" > ${ED}/etc/env.d/50slib

	dosbin installers/*
}

pkg_postinst() {
	[ "${ROOT}" == "/" ] && pkg_config
}

pkg_config() {
	for impl in ${IMPLEMENTATIONS}; do
		install_slib dev-scheme/${impl}
	done
}

make_installer() {
	echo $2 > install_slib_for_$1
}

install_slib() {
	if has_version $1; then
		script=install_slib_for_${1##*/}
		einfo "Registering slib with $1..."
		echo running: $(cat "${EPREFIX}"/usr/sbin/${script})
		$script
	else
		einfo "$1 not installed, not registering..."
	fi
}
