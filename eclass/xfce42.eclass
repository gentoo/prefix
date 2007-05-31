# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce42.eclass,v 1.8 2007/05/30 13:25:32 drac Exp $

# DEPRECATED ECLASS.

## set some variable values:
## COMPRESS is the default compression extension
## ZIP is added to src directory of Xfce packages for when upstream releases .tar.bz2 versions
## INSTALL is default make install directive
## XFCE_VERSION sets the minimum version required for the panel

COMPRESS=".tar.gz"

ZIP=""

INSTALL="make DESTDIR=${D} install"

XFCE_VERSION="4.2"

## plugins and base packages default to tar.gz unless bzipped is called
## ZIP is added to the src directory for when the Xfce team releases .tar.bz2 packages
bzipped() {
	COMPRESS=".tar.bz2"
	ZIP="-bz2"
}

## plugin function adds the -plugin string to $P and adds the depend on panel version
plugin() {
	[[ -z ${MY_P} ]] && MY_P="${PN}-plugin-${PV}"
	S="${WORKDIR}/${MY_P}"
	RDEPEND="${RDEPEND}
		=xfce-base/xfce4-panel-${XFCE_VERSION}*
		!>=xfce-base/xfce4-panel-4.3"
}

## goodies function sets SRC_URI and HOMEPAGE to berlios
goodies() {
	SRC_URI="http://download.berlios.de/xfce-goodies/${MY_P:-${P}}${COMPRESS}"
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://xfce-goodies.berlios.de/"
	S="${WORKDIR}/${MY_P:-${P}}"
}

## goodies_plugin calls plugin and goodies funtions in correct order
goodies_plugin() {
	plugin
	goodies
	S="${WORKDIR}/${MY_P}"
}

## core_package sets SRC_URI and HOMPAGE for all Xfce core pacgages
core_package() {
	SRC_URI="http://www.xfce.org/archive/xfce-${PV}/src${ZIP}/${P}${COMPRESS}"
	HOMEPAGE="http://www.xfce.org/"
}

## single_make sets the -j value to 1 eliminationg parallel builds for broken autotools scripts
single_make() {
	JOBS="-j1"
}

## want_einstall
want_einstall() {
	INSTALL="einstall"
}

## LICENSE is set to Xfce base packages default
LICENSE="GPL-2"
SLOT="0"

IUSE="${IUSE}"

RDEPEND=">=x11-libs/gtk+-2.2
		dev-libs/libxml2
		>=dev-libs/dbh-1.0.20
		>=x11-themes/gtk-engines-xfce-2.2.5
		${RDEPEND}"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"

#S="${WORKDIR}/${MY_P:-${P}}"

xfce42_src_compile() {
	## XFCE_CONFIG sets extra config parameters
	## JOBS is unset and defaults to make.conf settings
	## unless set by single_make
	econf ${XFCE_CONFIG} || die
	emake ${JOBS} || die
}

xfce42_src_install() {
	## INSTALL is default make install string
	${INSTALL} || die
}

EXPORT_FUNCTIONS src_compile src_install
