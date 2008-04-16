# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-plugins/gst-plugins-musepack/gst-plugins-musepack-0.10.6.ebuild,v 1.1 2008/02/21 14:23:45 zaheerm Exp $

EAPI="prefix"

inherit gst-plugins-bad

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"

RDEPEND=">=media-libs/gst-plugins-base-0.10.17
	>=media-libs/gstreamer-0.10.17
	>=media-libs/libmpcdec-1.2"

DEPEND="${RDEPEND}"
