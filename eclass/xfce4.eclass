# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xfce4.eclass,v 1.22 2006/10/14 20:27:21 swegener Exp $
# Author: Brad Cowan <bcowan@gentoo.org>

# Xfce4 Eclass
#
# Eclass to simplify Xfce4 package installation


if [[ ${BZIPPED} = "1" ]];then
	COMPRESS=".tar.bz2"
	ZIP="-bz2"
else
	COMPRESS=".tar.gz"
	ZIP=""
fi

if [[ ${GOODIES_PLUGIN} = "1" ]]; then
	[[ -z ${MY_P} ]] && MY_P="${PN}-plugin-${PV}"
	SRC_URI="http://download.berlios.de/xfce-goodies/${MY_P}${COMPRESS}"
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://xfce-goodies.berlios.de/"
	[[ -z ${XFCE_VERSION} ]] && XFCE_VERSION="4.2.0"
	RDEPEND="${RDEPEND} >=xfce-base/xfce4-panel-${XFCE_VERSION}"
fi

if [[ ${PLUGIN} = "1" ]]; then
	MY_P="${PN}-plugin-${PV}"
	[[ -z ${XFCE_VERSION} ]] && XFCE_VERSION="4.2.0"
	RDEPEND="${RDEPEND} >=xfce-base/xfce4-panel-${XFCE_VERSION}"
fi

if [[ ${GOODIES} = "1" ]]; then
	SRC_URI="http://download.berlios.de/xfce-goodies/${MY_P:-${P}}${COMPRESS}"
	[[ -z ${HOMEPAGE} ]] && HOMEPAGE="http://xfce-goodies.berlios.de/"
fi

[[ -n ${SRC_URI} ]] \
	|| SRC_URI="http://www.xfce.org/archive/xfce-${PV}/src${ZIP}/${P}${COMPRESS}"

[[ ${XFCE_META} = "1" ]] \
	&& SRC_URI=""

[[ -z ${LICENSE} ]] \
	&& LICENSE="GPL-2"

[[ -z ${HOMEPAGE} ]] \
	&& HOMEPAGE="http://www.xfce.org/"

SLOT="0"
IUSE="debug doc"

RDEPEND="virtual/x11
	>=x11-libs/gtk+-2.2
	dev-libs/libxml2
	x11-libs/startup-notification
	>=dev-libs/dbh-1.0.20
	>=x11-themes/gtk-engines-xfce-2.2.5
	${RDEPEND}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

[[ -z ${XFCE_S} ]] \
	&& S="${WORKDIR}/${MY_P:-${P}}" \
	|| S="${XFCE_S}"

xfce4_src_compile() {
	if [[ "${DEBUG_OFF}" = "1" ]] && use debug; then
		XFCE_CONFIG="${XFCE_CONFIG}"
	elif use debug; then
		XFCE_CONFIG="${XFCE_CONFIG} --enable-debug=yes"
	fi

	if [[ ${XFCE_META} = "1" ]]; then
		einfo "Meta Build, Nothing to compile."
	else
		econf ${XFCE_CONFIG} || die

		if [[ "${SINGLE_MAKE}" = "1" ]]; then
			emake -j1 || die
		else
			emake || die
		fi
	fi
}

xfce4_src_install() {
	if [[ ${XFCE_META} = "1" ]]; then
		einfo "Meta Build, Nothing to install."
	else
		if [[ "${WANT_EINSTALL}" = "1" ]]; then
			einstall || die
		else
				make DESTDIR=${D} install || die
		fi

		if use doc; then
			dodoc ${XFCE_DOCS} AUTHORS INSTALL README COPYING ChangeLog HACKING NEWS THANKS TODO
		fi
	fi
}

EXPORT_FUNCTIONS src_compile src_install
