# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Tree-DAG_Node/Tree-DAG_Node-1.05.ebuild,v 1.12 2007/07/13 21:36:40 armin76 Exp $

inherit perl-module

DESCRIPTION="(super)class for representing nodes in a tree"
HOMEPAGE="http://search.cpan.org/~sburke/"
SRC_URI="mirror://cpan/authors/id/S/SB/SBURKE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
