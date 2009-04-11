# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Tty/IO-Tty-1.08.ebuild,v 1.1 2009/02/25 20:39:10 tove Exp $

MODULE_AUTHOR=RGIERSIG
inherit perl-module

DESCRIPTION="IO::Tty and IO::Pty modules for Perl"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"
