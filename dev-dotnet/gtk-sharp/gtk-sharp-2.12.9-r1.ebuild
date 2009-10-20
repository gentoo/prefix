# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.12.9-r1.ebuild,v 1.2 2009/10/18 23:58:05 mr_bones_ Exp $

EAPI=2

inherit eutils gtk-sharp-module

SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RESTRICT="test"

src_prepare() {
	epatch "${FILESDIR}"/${P}-cellrenderer.patch
	gtk-sharp-module_src_prepare
}
