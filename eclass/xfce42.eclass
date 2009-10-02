# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce42.eclass,v 1.9 2009/09/30 09:22:36 ssuominen Exp $

# OBSOLETE ECLASS. Unused and doesn't work. Delete soon as allowed.

COMPRESS=".tar.gz"
ZIP=""
INSTALL="make DESTDIR=${D} install"
XFCE_VERSION="4.2"
HOMEPAGE=""

bzipped() {
	COMPRESS=".tar.bz2"
	ZIP="-bz2"
}

plugin() {
	[[ -z ${MY_P} ]] && MY_P="${PN}-plugin-${PV}"
	S="${WORKDIR}/${MY_P}"
	RDEPEND="${RDEPEND}
		=xfce-base/xfce4-panel-${XFCE_VERSION}*
		!>=xfce-base/xfce4-panel-4.3"
}

goodies() {
	SRC_URI="http://download.berlios.de/xfce-goodies/${MY_P:-${P}}${COMPRESS}"
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://xfce-goodies.berlios.de/"
	S="${WORKDIR}/${MY_P:-${P}}"
}

goodies_plugin() {
	plugin
	goodies
	S="${WORKDIR}/${MY_P}"
}

core_package() {
	SRC_URI="http://www.xfce.org/archive/xfce-${PV}/src${ZIP}/${P}${COMPRESS}"
}

single_make() {
	JOBS=""
}

want_einstall() {
	INSTALL="true"
}

LICENSE=""
SLOT="0"
IUSE="${IUSE}"

xfce42_src_compile() {
	true
}

xfce42_src_install() {
	true
}

EXPORT_FUNCTIONS src_compile src_install
