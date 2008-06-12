# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Hook-LexWrap/Hook-LexWrap-0.20.ebuild,v 1.12 2007/07/10 23:33:29 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Lexically scoped subroutine wrappers"
HOMEPAGE="http://search.cpan.org/~dconway/"
SRC_URI="mirror://cpan/authors/id/D/DC/DCONWAY/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
