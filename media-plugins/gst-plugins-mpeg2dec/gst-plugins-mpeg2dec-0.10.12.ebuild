# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-mpeg2dec/gst-plugins-mpeg2dec-0.10.12.ebuild,v 1.7 2009/11/29 17:37:01 klausman Exp $

inherit gst-plugins-ugly

DESCRIPTION="Libmpeg2 based decoder plug-in for gstreamer"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=media-libs/gst-plugins-base-0.10.23
	>=media-libs/gstreamer-0.10.23
	>=media-libs/libmpeg2-0.4"
