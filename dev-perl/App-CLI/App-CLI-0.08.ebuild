# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/App-CLI/App-CLI-0.08.ebuild,v 1.1 2009/02/26 11:41:32 tove Exp $

MODULE_AUTHOR=ALEXMV
inherit perl-module

DESCRIPTION="Dispatcher module for command line interface programs"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="dev-lang/perl
	>=virtual/perl-Getopt-Long-2.35
	virtual/perl-Locale-Maketext-Simple
	virtual/perl-Pod-Simple"
DEPEND="${RDEPEND}"

SRC_TEST="do"
