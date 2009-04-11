# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-alsa/gst-plugins-alsa-0.10.20.ebuild,v 1.9 2009/04/05 17:46:13 armin76 Exp $

inherit gst-plugins-base

KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.20
	media-libs/alsa-lib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
