# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Remove/File-Remove-1.42.ebuild,v 1.3 2009/07/02 19:34:26 jer Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Remove files and directories"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=virtual/perl-File-Spec-0.84
	dev-lang/perl"

SRC_TEST="do"
