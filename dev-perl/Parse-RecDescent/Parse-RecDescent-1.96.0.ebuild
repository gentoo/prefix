# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Parse-RecDescent/Parse-RecDescent-1.96.0.ebuild,v 1.1 2009/04/23 07:12:33 tove Exp $

EAPI=2

MODULE_AUTHOR=DCONWAY
inherit perl-module

DESCRIPTION="Parse::RecDescent - generate recursive-descent parsers"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="virtual/perl-Text-Balanced
	virtual/perl-version"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build"

SRC_TEST="do"

src_install() {
	perl-module_src_install
	dohtml -r tutorial
}
