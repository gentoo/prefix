# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce44.eclass,v 1.24 2009/09/30 09:13:19 ssuominen Exp $

# OBSOLETE ECLASS. Unused and doesn't work. Delete soon as allowed.

inherit fdo-mime gnome2-utils

LICENSE=""
SLOT="0"
IUSE="${IUSE}"
COMPRESS=".tar.bz2"
CONFIGURE="econf"
INSTALL="emake DESTDIR=${D} install"
XFCE_BETA_VERSION="4.3.99.2"
XFCE_VERSION="4.4.0"
THUNAR_BETA_VERSION="0.5.0_rc2"
THUNAR_VERSION="0.8"
HOMEPAGE=""

xfce44_beta() {
	XFCE_MASTER_VERSION=${XFCE_BETA_VERSION}
	THUNAR_MASTER_VERSION=${THUNAR_BETA_VERSION}
}

xfce44() {
	XFCE_MASTER_VERSION=${XFCE_VERSION}
	THUNAR_MASTER_VERSION=${THUNAR_VERSION}
}

xfce44_gzipped() {
	COMPRESS=".tar.gz"
}

xfce44_zipped() {
	COMPRESS=".zip"
}

xfce44_plugin() {
	[[ -z ${MY_PN} ]] && MY_PN="${PN}-plugin"
	[[ -z ${MY_P} ]] && MY_P="${MY_PN}-${PV}"
	S="${WORKDIR}/${MY_P}"
	[[ -z ${XFCE_MASTER_VERSION} ]] && XFCE_MASTER_VERSION=${XFCE_VERSION}
	[[ -z ${THUNAR_MASTER_VERSION} ]] && THUNAR_MASTER_VERSION=${THUNAR_VERSION}
}

xfce44_panel_plugin() {
	xfce44_plugin
}

xfce44_thunar_plugin() {
	xfce44_plugin
}

xfce44_goodies() {
	S="${WORKDIR}/${MY_P:-${P}}"
	SRC_URI="http://goodies.xfce.org/releases/${MY_PN:-${PN}}/${MY_P:-${P}}${COMPRESS}"
}

xfce44_goodies_panel_plugin() {
	xfce44_panel_plugin
	xfce44_goodies
}

xfce44_goodies_thunar_plugin() {
	xfce44_thunar_plugin
	xfce44_goodies
}

xfce44_core_package() {
	SRC_URI="http://www.xfce.org/archive/xfce-${XFCE_MASTER_VERSION}/src/${P}${COMPRESS}"
}

xfce44_extra_package() {
	[[ -z ${MY_P} ]] && MY_P=${P}
	SRC_URI="http://www.xfce.org/archive/xfce-${XFCE_MASTER_VERSION}/src/${MY_P}${COMPRESS}"
}

xfce44_single_make() {
	JOBS=""
}

xfce44_want_einstall() {
	INSTALL="true"
}

xfce44_src_compile() {
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
	emake ${JOBS}
}

xfce44_src_install() {
	[[ -n "${DOCS}" ]] && dodoc ${DOCS}
	${INSTALL} ${JOBS}
}

xfce44_pkg_preinst() {
	true
}

xfce44_pkg_postinst() {
	true
}

xfce44_pkg_postrm() {
	true
}

EXPORT_FUNCTIONS src_compile src_install pkg_preinst pkg_postinst pkg_postrm
