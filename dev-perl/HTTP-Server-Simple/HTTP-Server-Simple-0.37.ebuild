# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTTP-Server-Simple/HTTP-Server-Simple-0.37.ebuild,v 1.1 2009/01/04 11:33:58 tove Exp $

#MODULE_AUTHOR=ALEXMV
MODULE_AUTHOR=JESSE
inherit perl-module eutils

DESCRIPTION="Lightweight HTTP Server"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND="dev-lang/perl
	dev-perl/URI"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

SRC_TEST="do"
#PATCHES=( "${FILESDIR}/${PV}-debian.patch" )
