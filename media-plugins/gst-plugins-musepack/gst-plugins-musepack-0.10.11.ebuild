# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-musepack/gst-plugins-musepack-0.10.11.ebuild,v 1.8 2009/07/25 22:50:20 ssuominen Exp $

inherit gst-plugins-bad

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.22
	>=media-libs/gstreamer-0.10.22
	|| ( >=media-sound/musepack-tools-444 >=media-libs/libmpcdec-1.2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
