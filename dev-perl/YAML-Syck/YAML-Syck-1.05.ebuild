# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/YAML-Syck/YAML-Syck-1.05.ebuild,v 1.4 2009/01/09 22:33:06 josejx Exp $

MODULE_AUTHOR=AUDREYT
inherit perl-module

DESCRIPTION="Fast, lightweight YAML loader and dumper"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="|| ( dev-libs/syck >=dev-lang/ruby-1.8 )
	dev-lang/perl"
