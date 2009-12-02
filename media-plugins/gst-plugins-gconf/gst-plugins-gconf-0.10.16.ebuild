# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-gconf/gst-plugins-gconf-0.10.16.ebuild,v 1.8 2009/11/29 17:31:49 klausman Exp $

GCONF_DEBUG=no

inherit gnome2 gst-plugins-good gst-plugins10

DESCRIPTION="GStreamer plugin for wrapping GConf audio/video settings"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND=">=gnome-base/gconf-2
	>=media-libs/gstreamer-0.10.24
	>=media-libs/gst-plugins-base-0.10.24"

GST_PLUGINS_BUILD="gconf gconftool"
