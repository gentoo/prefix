# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Regexp-Shellish/Regexp-Shellish-0.93.ebuild,v 1.16 2007/07/10 23:33:30 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Regexp::Shellish - Shell-like regular expressions"
HOMEPAGE="http://search.cpan.org/~rbs/"
SRC_URI="mirror://cpan/authors/id/R/RB/RBS/${P}.tar.gz"

SLOT="0"
LICENSE="Artistic"
SRC_TEST="do"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"
