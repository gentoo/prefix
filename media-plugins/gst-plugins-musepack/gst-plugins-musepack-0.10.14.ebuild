# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-musepack/gst-plugins-musepack-0.10.14.ebuild,v 1.1 2009/09/07 05:15:42 tester Exp $

inherit gst-plugins-bad

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.24
	>=media-libs/gstreamer-0.10.24
	|| ( >=media-sound/musepack-tools-444 >=media-libs/libmpcdec-1.2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
