# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-x/gst-plugins-x-0.10.23.ebuild,v 1.1 2009/05/11 03:25:33 tester Exp $

inherit gst-plugins-base

KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.23
	x11-libs/libX11"
DEPEND="${RDEPEND}
	x11-proto/xproto"

# xshm is a compile time option of ximage
GST_PLUGINS_BUILD="x xshm"
GST_PLUGINS_BUILD_DIR="ximage"
