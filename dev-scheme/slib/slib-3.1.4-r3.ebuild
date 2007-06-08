# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/slib/slib-3.1.4-r3.ebuild,v 1.2 2007/06/07 18:10:34 hkbst Exp $

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

INSTALL_DIR="/usr/share/slib/"

src_unpack() {
	unpack "${A}"; cd ${S}

	epatch ${FILESDIR}/Makefile.patch

	sed "s_prefix = /usr/local/_prefix = ${ED}/usr/_" -i Makefile
	sed 's:libdir = $(exec_prefix)lib/:libdir = $(exec_prefix)share/:' -i Makefile
	sed 's_mandir = $(prefix)man/_mandir = $(prefix)/share/man/_' -i Makefile
	sed 's_infodir = $(prefix)info/_infodir = $(prefix)share/info/_' -i Makefile

	sed 's:echo SCHEME_LIBRARY_PATH=$(libslibdir)  >> $(bindir)slib:echo SCHEME_LIBRARY_PATH='"${EPREFIX}"'/usr/share/slib/ >> $(bindir)slib:' -i Makefile

	sed 's_mkdir_mkdir -p_g' -i Makefile

#	for dir in mandir infodir srcdir htmldir; do
#		sed "s_\$(${dir})_\$(${dir})/_g" -i Makefile
#	done

#	einstall || die "install failed"
#	emake infodir="${ED}/usr/share/info/" mandir="${ED}/usr/share/doc/${P}/" infoz || die "infoz failed"

	sed 's:(lambda () "/usr/local/share/gambc/")):(lambda () "'"${EPREFIX}"'/usr/share/gambit")):' -i gambit.init
}

src_compile() {
	emake infoz || die "infoz failed"
}

src_install() {
	emake install || die "install failed"

	dodoc ANNOUNCE ChangeLog FAQ README
	dodir /usr/share/gambit/
	more_install
}

# maybe also do "make infoz"
_src_install() {
	insinto ${INSTALL_DIR} #don't install directly into guile dir
	doins *.scm
	doins *.init
	dodoc ANNOUNCE ChangeLog FAQ README
	doinfo slib.info
	more_install
}

more_install() {
	dosym ${INSTALL_DIR} /usr/share/guile/slib # link from guile dir
	dosym ${INSTALL_DIR} /usr/lib/slib
	dodir /etc/env.d/ && echo "SCHEME_LIBRARY_PATH=\"${EPREFIX}${INSTALL_DIR}\"" > ${ED}/etc/env.d/50slib

	mkdir ${S}/installers
	pushd installers; make_installers; popd
	dosbin installers/*
}

pkg_postinst() {
	[ "${ROOT}" == "/" ] && pkg_config
}

IMPLEMENTATIONS="bigloo drscheme elk gambit guile scm" # mit-scheme

pkg_config() {
	for impl in ${IMPLEMENTATIONS}; do
		install_slib ${impl}
#		echo '(slib:report-version)' | slib ${impl}
	done
}

make_load_expression() {
	echo "(load \\\"${EPREFIX}${INSTALL_DIR}$1.init\\\")"
}

make_installers()
{
	PROGRAM="(require 'new-catalog) (slib:report-version)"

	bigloo_install_command="bigloo -s -eval \"(begin "$(make_load_expression bigloo)" ${PROGRAM} (exit))\""
	drscheme_install_command="mzscheme -vme \"(begin $(make_load_expression DrScheme) ${PROGRAM})\""
	elk_install_command="echo \"$(make_load_expression elk) ${PROGRAM}\" | elk -l -"
	gambit_install_command="gambit-interpreter -e \"$(make_load_expression gambit) ${PROGRAM}\""
	guile_install_command="guile -c \"$(make_load_expression guile) ${PROGRAM}\""
	#variable names may not contain hyphens (-)
	mitscheme_install_command="echo \"(set! load/suppress-loading-message? #t) $(make_load_expression mitscheme) ${PROGRAM}\" | mit-scheme --batch-mode"
	echo ${mitscheme_install_command}
	scm_install_command="scm -e \"${PROGRAM}\""

	for impl in ${IMPLEMENTATIONS}; do
		command_var=${impl//-/}_install_command
		make_installer ${impl} "${!command_var}"
	done
}

make_installer() {
	echo $2 > install_slib_for_${1//-/}
}

install_slib() {
	if has_version dev-scheme/$1; then
		script=install_slib_for_${1//-/}
		einfo "Registering slib with $1..."
#		echo running: $(cat "${EPREFIX}"/usr/sbin/${script})
		$script
	else
		einfo "$1 not installed, not registering..."
	fi
}
