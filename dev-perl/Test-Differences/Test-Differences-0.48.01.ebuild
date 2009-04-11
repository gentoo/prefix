# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Differences/Test-Differences-0.48.01.ebuild,v 1.1 2008/12/08 07:45:48 robbat2 Exp $

inherit versionator
MY_P=${PN}-$(delete_version_separator 2)
S=${WORKDIR}/${MY_P}
MODULE_AUTHOR=OVID
inherit perl-module

DESCRIPTION="Test strings and data structures and show differences if not ok"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-perl/Text-Diff
	dev-lang/perl"
