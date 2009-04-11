# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/File-Temp/File-Temp-0.21.ebuild,v 1.2 2009/01/01 19:40:19 armin76 Exp $

MODULE_AUTHOR=TJENNESS
inherit perl-module

DESCRIPTION="File::Temp can be used to create and open temporary files in a safe way."

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
