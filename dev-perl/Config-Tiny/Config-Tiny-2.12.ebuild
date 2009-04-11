# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Config-Tiny/Config-Tiny-2.12.ebuild,v 1.3 2008/09/30 12:06:49 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Read/Write .ini style files with as little code as possible"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
