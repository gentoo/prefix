# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mixer/xfce4-mixer-4.6.1.ebuild,v 1.1 2009/04/21 04:29:58 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_core

DESCRIPTION="Volume control application using gstreamer"
HOMEPAGE="http://www.xfce.org/projects/xfce4-mixer"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

IUSE="alsa debug oss"

RDEPEND=">=dev-libs/glib-2.12:2
	>=media-libs/gst-plugins-base-0.10.2
	>=x11-libs/gtk+-2.10:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}
	>=xfce-base/libxfcegui4-${XFCE_VERSION}
	>=xfce-base/xfce4-panel-${XFCE_VERSION}
	>=xfce-base/xfconf-${XFCE_VERSION}
	alsa? ( media-plugins/gst-plugins-alsa )
	oss? ( media-plugins/gst-plugins-oss )"
DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"
