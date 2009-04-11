# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Getopt-Long/Getopt-Long-2.38.ebuild,v 1.2 2009/04/04 17:32:22 armin76 Exp $

EAPI=2

MODULE_AUTHOR=JV
inherit perl-module

DESCRIPTION="Advanced handling of command line options"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="virtual/perl-PodParser"
DEPEND="${RDEPEND}"

SRC_TEST=do
