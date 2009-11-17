# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Locale-Maketext-Simple/Locale-Maketext-Simple-0.21.ebuild,v 1.1 2009/08/18 20:44:33 tove Exp $

EAPI=2

MODULE_AUTHOR=JESSE
inherit perl-module

DESCRIPTION="Locale::Maketext::Simple - Simple interface to Locale::Maketext::Lexicon"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~ppc-macos"
IUSE="test"

RDEPEND=""
DEPEND="test? ( dev-perl/locale-maketext-lexicon )"

SRC_TEST="do"
