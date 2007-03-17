# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce44.eclass,v 1.18 2007/03/07 19:37:16 drac Exp $

# Xfce44 Eclass
#
# Eclass to simplify Xfce4 package installation

inherit fdo-mime gnome2-utils

## set some variable values:
## COMPRESS is the default compression extension
## INSTALL is default gmake install directive
## *_VERSION sets the minimum version required for the panel
## LICENSE is set to Xfce base packages default

LICENSE="GPL-2"
SLOT="0"

IUSE="${IUSE}"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

#S="${WORKDIR}/${MY_P:-${P}}"

COMPRESS=".tar.bz2"
CONFIGURE="econf"
INSTALL="emake DESTDIR=${D} install"

XFCE_BETA_VERSION="4.3.99.2"
XFCE_VERSION="4.4.0"
THUNAR_BETA_VERSION="0.5.0_rc2"
THUNAR_VERSION="0.8"

## sets {XFCE,THUNAR}_MASTER_VESION to {XFCE,THUNR}_BETA_VERSION
xfce44_beta() {
	XFCE_MASTER_VERSION=${XFCE_BETA_VERSION}
	THUNAR_MASTER_VERSION=${THUNAR_BETA_VERSION}
}

xfce44() {
	XFCE_MASTER_VERSION=${XFCE_VERSION}
	THUNAR_MASTER_VERSION=${THUNAR_VERSION}
}

## plugins and base packages default to tar.bz2 unless gzipped is called
xfce44_gzipped() {
	COMPRESS=".tar.gz"
}

## adds the -plugin string to $P and adds the depend on panel version
xfce44_plugin() {
	[[ -z ${MY_PN} ]] && MY_PN="${PN}-plugin"
	[[ -z ${MY_P} ]] && MY_P="${MY_PN}-${PV}"
	S="${WORKDIR}/${MY_P}"
	[[ -z ${XFCE_MASTER_VERSION} ]] && XFCE_MASTER_VERSION=${XFCE_VERSION}
	[[ -z ${THUNAR_MASTER_VERSION} ]] && THUNAR_MASTER_VERSION=${THUNAR_VERSION}
}

xfce44_panel_plugin() {
	xfce44_plugin
	RDEPEND="${RDEPEND} >=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}"
	DEPEND="${DEPEND} >=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}"
}

xfce44_thunar_plugin() {
	xfce44_plugin
	HOMEPAGE="http://thunar.xfce.org/pwiki/projects/${MY_PN}"
	RDEPEND="${RDEPEND} >=xfce-base/thunar-${THUNAR_MASTER_VERSION}"
	DEPEND="${DEPEND} >=xfce-base/thunar-${THUNAR_MASTER_VERSION}"
}

## sets SRC_URI and HOMEPAGE to berlios
xfce44_goodies() {
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://goodies.xfce.org"
	S="${WORKDIR}/${MY_P:-${P}}"
	SRC_URI="http://goodies.xfce.org/releases/${MY_PN}/${MY_P}${COMPRESS}"
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

## sets SRC_URI and HOMPAGE for all Xfce core packages
xfce44_core_package() {
	SRC_URI="http://www.xfce.org/archive/xfce-${XFCE_MASTER_VERSION}/src/${P}${COMPRESS}"
	HOMEPAGE="http://www.xfce.org/"
}

## sets SRC_URI for non-core packages, like xarchiver
xfce44_extra_package() {
	[[ -z ${MY_P} ]] && MY_P=${P}
	SRC_URI="http://www.xfce.org/archive/xfce-${XFCE_MASTER_VERSION}/src/${MY_P}${COMPRESS}"
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

xfce44_src_compile() {
	## XFCE_CONFIG sets extra config parameters
	if has doc ${IUSE}; then
		XFCE_CONFIG="${XFCE_CONFIG} $(use_enable doc gtk-doc)"
	fi

	if has startup-notification ${IUSE}; then
		XFCE_CONFIG="${XFCE_CONFIG} $(use_enable startup-notification)"
	fi

	if has debug ${IUSE}; then
		XFCE_CONFIG="${XFCE_CONFIG} $(use_enable debug)"
	fi
	${CONFIGURE} ${XFCE_CONFIG}
	## JOBS is unset and defaults to make.conf settings
	## unless set by single_make
	emake ${JOBS} || die
}

xfce44_src_install() {
	## Install documentation from sources defined in DOCS
	[[ -n "${DOCS}" ]] && dodoc ${DOCS}

	## INSTALL is default make install string
	${INSTALL} || die
}

xfce44_pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

xfce44_pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm
