# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test-Harness/Test-Harness-3.17.ebuild,v 1.1 2009/05/06 08:16:13 tove Exp $

MODULE_AUTHOR=ANDYA
inherit perl-module

DESCRIPTION="Runs perl standard test scripts with statistics"

SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

PREFER_BUILDPL=no
SRC_TEST="do"
mydoc="rfc*.txt"
