# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Script/Test-Script-1.03.ebuild,v 1.7 2008/07/17 20:51:29 armin76 Exp $

MODULE_AUTHOR=ADAMK

inherit perl-module

DESCRIPTION="Cross-platform basic tests for scripts"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lang/perl
	virtual/perl-File-Spec
	dev-perl/IPC-Run3
	virtual/perl-Test-Simple"

SRC_TEST=do
