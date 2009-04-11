# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTML-Tree/HTML-Tree-3.23.ebuild,v 1.15 2008/09/30 13:59:05 tove Exp $

MODULE_AUTHOR=PETEK
inherit perl-module

DESCRIPTION="A library to manage HTML-Tree in PERL"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/HTML-Tagset-3.03
	>=dev-perl/HTML-Parser-3.46
	dev-lang/perl"

SRC_TEST="do"
