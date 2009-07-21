# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Encode-Detect/Encode-Detect-1.01.ebuild,v 1.3 2009/07/20 07:50:29 tove Exp $

MODULE_AUTHOR=JGMYERS
inherit perl-module

DESCRIPTION="Encode::Detect - An Encode::Encoding subclass that detects the encoding of data"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND="virtual/perl-Module-Build
	virtual/perl-ExtUtils-CBuilder"

SRC_TEST=do
