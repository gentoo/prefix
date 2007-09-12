# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-x/gst-plugins-x-0.10.14.ebuild,v 1.4 2007/09/10 17:12:48 nixnut Exp $

EAPI="prefix"

inherit gst-plugins-base

KEYWORDS="~amd64 ~ia64 ~x86"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.13.1
	 x11-libs/libX11"
DEPEND="${RDEPEND}
	x11-proto/xproto"

# xshm is a compile time option of ximage
GST_PLUGINS_BUILD="x xshm"
GST_PLUGINS_BUILD_DIR="ximage"
