# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/String-Format/String-Format-1.14.ebuild,v 1.9 2008/02/20 19:50:24 nixnut Exp $

inherit perl-module

DESCRIPTION="sprintf-like string formatting capabilities with arbitrary format definitions"
HOMEPAGE="http://search.cpan.org/~darren/"
SRC_URI="mirror://cpan/authors/id/D/DA/DARREN/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
