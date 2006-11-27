# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce44.eclass,v 1.2 2006/07/10 18:31:49 bcowan Exp $

# Xfce44 Eclass
#
# Eclass to simplify Xfce4 package installation

inherit debug

## set some variable values:
## COMPRESS is the default compression extension
## INSTALL is default make install directive
## *_VERSION sets the minimum version required for the panel

COMPRESS=".tar.bz2"

INSTALL="make DESTDIR=${D} install"

XFCE_BETA_VERSION="4.3.90.2"
XFCE_VERSION="4.4"
THUNAR_BETA_VERSION="0.3.2_beta2"
THUNAR_VERSION="1.0"

## sets {XFCE,THUNAR}_MASTER_VESION to {XFCE,THUNR}_BETA_VERSION
xfce44_beta() {
	XFCE_MASTER_VERSION=${XFCE_BETA_VERSION}
	THUNAR_MASTER_VERSION=${THUNAR_BETA_VERSION}
}

## plugins and base packages default to tar.bz2 unless gzipped is called
xfce44_gzipped() {
	COMPRESS=".tar.gz"
}

## adds the -plugin string to $P and adds the depend on panel version
xfce44_plugin() {
	[[ -z ${MY_P} ]] && MY_P="${PN}-plugin-${PV}"
	S="${WORKDIR}/${MY_P}"
	[[ -z ${XFCE_MASTER_VERSION} ]] && XFCE_MASTER_VERSION=${XFCE_VERSION}
	[[ -z ${THUNAR_MASTER_VERSION} ]] && THUNAR_MASTER_VERSION=${THUNAR_VERSION}
}

xfce44_panel_plugin() {
	xfce44_plugin
	RDEPEND="${RDEPEND} >=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}"
}

xfce44_thunar_plugin() {
	xfce44_plugin
	RDEPEND="${RDEPEND} >=xfce-base/thunar-${THUNAR_MASTER_VERSION}"
}

## sets SRC_URI and HOMEPAGE to berlios
xfce44_goodies() {
	SRC_URI="http://download.berlios.de/xfce-goodies/${MY_P:-${P}}${COMPRESS}"
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://xfce-goodies.berlios.de/"
	S="${WORKDIR}/${MY_P:-${P}}"
}

## goodies_panel_plugin calls panel_plugin and goodies funtions in correct order
xfce44_goodies_panel_plugin() {
	xfce44_panel_plugin
	xfce44_goodies
}

## calls thunar_plugin and goodies funtions in correct order
xfce44_goodies_thunar_plugin() {
	xfce44_thunar_plugin
	xfce44_goodies
}

## sets SRC_URI and HOMPAGE for all Xfce core pacgages
xfce44_core_package() {
	SRC_URI="http://www.xfce.org/archive/xfce-${PV}/src/${P}${COMPRESS}"
	HOMEPAGE="http://www.xfce.org/"
}

## single_make sets the -j value to 1 eliminationg parallel builds for broken autotools scripts
xfce44_single_make() {
	JOBS="-j1"
}

## want_einstall
xfce44_want_einstall() {
	INSTALL="einstall"
}

## LICENSE is set to Xfce base packages default
LICENSE="GPL-2"
SLOT="0"

IUSE="${IUSE}"

DEPEND="${RDEPEND}
		dev-util/pkgconfig"

#S="${WORKDIR}/${MY_P:-${P}}"

xfce44_src_compile() {
	## XFCE_CONFIG sets extra config parameters
	## JOBS is unset and defaults to make.conf settings
	## unless set by single_make
	econf ${XFCE_CONFIG} || die
	emake ${JOBS} || die
}

xfce44_src_install() {
	## INSTALL is default make install string
	${INSTALL} || die
}

EXPORT_FUNCTIONS src_compile src_install
