# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfdesktop/xfdesktop-4.6.1-r1.ebuild,v 1.1 2009/09/23 11:09:56 ssuominen Exp $

EAPI=2
EAUTORECONF=yes
inherit xfconf

DESCRIPTION="Desktop manager for Xfce4"
HOMEPAGE="http://www.xfce.org/projects/xfdesktop"
SRC_URI="mirror://xfce/src/xfce/${PN}/4.6/${P}.tar.bz2
	branding? ( http://www.gentoo.org/images/backgrounds/gentoo-minimal-1280x1024.jpg )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+branding debug doc +menu-plugin thunar"

LINGUAS="be ca cs da de el es et eu fi fr he hu it ja ko nb_NO nl pa pl pt_BR ro ru sk sv tr uk vi zh_CN zh_TW"

for X in ${LINGUAS}; do
	IUSE="${IUSE} linguas_${X}"
done

RDEPEND="gnome-base/libglade
	x11-libs/libX11
	x11-libs/libSM
	>=x11-libs/libwnck-2.12
	>=dev-libs/glib-2.10:2
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-4.6
	>=xfce-base/libxfcegui4-4.6
	>=xfce-base/libxfce4menu-4.6
	>=xfce-base/xfconf-4.6
	branding? ( >=x11-libs/gtk+-2.10:2[jpeg] )
	thunar? ( >=xfce-base/thunar-1
		>=xfce-base/exo-0.3.100
		dev-libs/dbus-glib )
	menu-plugin? ( >=xfce-base/xfce4-panel-4.6 )"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig
	doc? ( dev-libs/libxslt )"

pkg_setup() {
	XFCE_LOCALIZED_CONFIGS="/etc/xdg/xfce4/desktop/menu.xml
		/etc/xdg/xfce4/desktop/xfce-registered-categories.xml"
	XFCONF="--disable-dependency-tracking
		$(use_enable thunar file-icons)
		$(use_enable thunar thunarx)
		$(use_enable thunar exo)
		$(use_enable menu-plugin panel-plugin)
		$(use_enable doc xsltproc)
		$(use_enable debug)"
	DOCS="AUTHORS ChangeLog NEWS TODO README"
	PATCHES=( "${FILESDIR}/${P}-automagic.patch" )
}

src_prepare() {
	if use branding; then
		sed -i -e "s:xfce-stripes.png:gentoo-minimal-1280x1024.jpg:" \
			common/xfdesktop-common.h || die "sed failed"
	fi
	xfconf_src_prepare
}

src_install() {
	xfconf_src_install

	if use branding; then
		insinto /usr/share/xfce4/backdrops
		doins "${DISTDIR}"/gentoo-minimal-1280x1024.jpg || die "doins failed"
	fi

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
