# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mixer/xfce4-mixer-4.4.3.ebuild,v 1.8 2008/12/15 05:03:27 jer Exp $

EAPI="prefix 1"

inherit eutils xfce44

XFCE_VERSION=4.4.3

xfce44
xfce44_core_package

# Bugs 166167 and 174296. Parallel make is dead in xfce4-mixer.
xfce44_single_make

DESCRIPTION="Volume control application (ALSA or OSS)"
HOMEPAGE="http://www.xfce.org/projects/xfce4-mixer"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

IUSE="alsa debug nls"

RDEPEND=">=dev-libs/glib-2.6:2
	dev-libs/libxml2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce4-panel-${XFCE_MASTER_VERSION}
	alsa? ( media-libs/alsa-lib )"
DEPEND="${RDEPEND}
	dev-util/intltool"

if use alsa; then
	XFCE_CONFIG+=" --with-sound=alsa"
fi

XFCE_CONFIG+=" $(use_enable nls)"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm panel-plugin/${PN}.desktop
}

src_install() {
	xfce44_src_install
	make_desktop_entry ${PN} "Volume Control" ${PN} AudioVideo
}

DOCS="AUTHORS ChangeLog NEWS NOTES README TODO"
