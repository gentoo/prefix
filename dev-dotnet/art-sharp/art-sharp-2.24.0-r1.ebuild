# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/art-sharp/art-sharp-2.24.0-r1.ebuild,v 1.1 2008/11/28 00:21:07 loki_val Exp $

EAPI="prefix 2"

GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="${DEPEND}
	>=dev-dotnet/gtk-sharp-2.12[glade]
	media-libs/libart_lgpl"
