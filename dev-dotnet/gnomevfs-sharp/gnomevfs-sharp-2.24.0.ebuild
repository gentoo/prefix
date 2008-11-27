# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gnomevfs-sharp/gnomevfs-sharp-2.24.0.ebuild,v 1.2 2008/11/26 10:46:41 loki_val Exp $

EAPI="prefix 2"

GTK_SHARP_REQUIRED_VERSION="2.12"

inherit gtk-sharp-module

SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-dotnet/gtk-sharp-2.12.6[glade]
	>=gnome-base/gnome-vfs-2.24"
DEPEND="${RDEPEND} dev-util/pkgconfig"
