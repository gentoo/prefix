# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-musepack/gst-plugins-musepack-0.10.11.ebuild,v 1.6 2009/05/21 19:02:01 ranger Exp $

inherit gst-plugins-bad

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.22
	>=media-libs/gstreamer-0.10.22
	>=media-libs/libmpcdec-1.2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
