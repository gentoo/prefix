# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTTP-Server-Simple/HTTP-Server-Simple-0.34.ebuild,v 1.1 2008/08/26 08:04:43 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=JESSE
inherit perl-module eutils

DESCRIPTION="Lightweight HTTP Server"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl
	dev-perl/URI"

SRC_TEST="do"
PATCHES="${FILESDIR}/${PV}-debian.patch"
