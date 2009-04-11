# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-mpeg2dec/gst-plugins-mpeg2dec-0.10.10.ebuild,v 1.1 2008/12/05 22:16:38 ssuominen Exp $

inherit gst-plugins-ugly

DESCRIPTION="Libmpeg2 based decoder plug-in for gstreamer"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=media-libs/gst-plugins-base-0.10.21
	>=media-libs/gstreamer-0.10.21
	>=media-libs/libmpeg2-0.4"
