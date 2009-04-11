# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pod-Simple/Pod-Simple-3.05.ebuild,v 1.11 2008/06/06 08:53:08 aballier Exp $

inherit perl-module

DESCRIPTION="framework for parsing Pod"
HOMEPAGE="http://search.cpan.org/~arandal/"
SRC_URI="mirror://cpan/authors/id/A/AR/ARANDAL/${P}.tar.gz"

SRC_TEST="do"
LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/Pod-Escapes-1.04
	dev-lang/perl"
