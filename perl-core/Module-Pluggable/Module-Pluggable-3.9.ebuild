# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Module-Pluggable/Module-Pluggable-3.9.ebuild,v 1.7 2009/04/25 17:35:55 armin76 Exp $

EAPI=2

MODULE_AUTHOR=SIMONW
inherit perl-module

DESCRIPTION="automatically give your module the ability to have plugins"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="virtual/perl-File-Spec"
DEPEND="${RDEPEND}"

SRC_TEST="do"
