# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/art-sharp/art-sharp-2.16.0.ebuild,v 1.7 2008/10/04 18:48:34 mabi Exp $

EAPI="prefix"

GTK_SHARP_TARBALL_PREFIX="gnome-sharp"
GTK_SHARP_REQUIRED_VERSION="2.10"

inherit gtk-sharp-component

SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="${DEPEND}
	>=media-libs/libart_lgpl-2.3.16
	dev-util/pkgconfig"

GTK_SHARP_COMPONENT_SLOT="2"
GTK_SHARP_COMPONENT_SLOT_DEC="-2.0"
