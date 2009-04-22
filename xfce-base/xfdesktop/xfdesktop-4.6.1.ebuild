# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfdesktop/xfdesktop-4.6.1.ebuild,v 1.1 2009/04/21 04:27:04 darkside Exp $

EAPI="1"

inherit eutils xfce4

xfce4_core

DESCRIPTION="Desktop manager"
HOMEPAGE="http://www.xfce.org/projects/xfdesktop"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug doc +file-icons +menu-plugin"

LINGUAS="be ca cs da de el es et eu fi fr he hu it ja ko nb_NO nl pa pl pt_BR ro ru sk sv tr uk vi zh_CN zh_TW"

RDEPEND="gnome-base/libglade
	x11-libs/libX11
	x11-libs/libSM
	>=x11-libs/libwnck-2.12
	>=dev-libs/glib-2.10:2
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/libxfce4menu-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	file-icons? ( >=xfce-base/thunar-0.9.92
		>=xfce-extra/exo-0.3.100 dev-libs/dbus-glib )
	menu-plugin? ( >=xfce-base/xfce4-panel-${XFCE_VERSION} )"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-libs/libxslt )"

for X in ${LINGUAS}; do
	IUSE="${IUSE} linguas_${X}"
done

XFCE_LOCALIZED_CONFIGS="/etc/xdg/xfce4/desktop/xfce-registered-categories.xml
	/etc/xdg/xfce4/desktop/menu.xml"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable doc xsltproc) $(use_enable menu-plugin panel-plugin)"

	if use file-icons; then
		XFCE_CONFIG+=" --enable-thunarx --enable-file-icons --enable-exo
		--enable-desktop-icons"
	else
		XFCE_CONFIG+=" --disable-thunarx --disable-file-icons --disable-exo
		--disable-desktop-icons"
	fi
}

src_install() {
	xfce4_src_install

	local config lang
	for config in ${XFCE_LOCALIZED_CONFIGS}; do
		for lang in ${LINGUAS}; do
			local localized_config="${ED}/${config}.${lang}"
			if [[ -f ${localized_config} ]]; then
				use "linguas_${lang}" || rm ${localized_config}
			fi
		done
	done
}

DOCS="AUTHORS ChangeLog NEWS TODO README"
