# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-alsa/gst-plugins-alsa-0.10.21.ebuild,v 1.1 2008/12/05 19:54:20 ssuominen Exp $

inherit gst-plugins-base

KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.21
	media-libs/alsa-lib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
