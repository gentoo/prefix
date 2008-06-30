# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-musepack/gst-plugins-musepack-0.10.7.ebuild,v 1.1 2008/06/29 18:18:05 drac Exp $

EAPI="prefix"

inherit gst-plugins-bad

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=media-libs/gst-plugins-base-0.10.19
	>=media-libs/gstreamer-0.10.19
	>=media-libs/libmpcdec-1.2"
