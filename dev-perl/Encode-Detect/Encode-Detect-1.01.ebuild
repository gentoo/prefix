# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Encode-Detect/Encode-Detect-1.01.ebuild,v 1.1 2008/08/23 19:35:29 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=JGMYERS
inherit perl-module

DESCRIPTION="Encode::Detect - An Encode::Encoding subclass that detects the encoding of data"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl
	dev-perl/ExtUtils-CBuilder"

SRC_TEST=do
