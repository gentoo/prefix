# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-x/gst-plugins-x-0.10.25.ebuild,v 1.1 2009/11/16 01:54:33 leio Exp $

inherit gst-plugins-base

KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xextproto"

# xshm is a compile time option of ximage, which is in libXext
GST_PLUGINS_BUILD="x xshm"
GST_PLUGINS_BUILD_DIR="ximage"
