# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Algorithm-Diff/Algorithm-Diff-1.1902.ebuild,v 1.6 2007/11/10 11:49:13 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Algorithm::Diff - Compute intelligent differences between two files / lists"
HOMEPAGE="http://search.cpan.org/~tyemq/"
SRC_URI="mirror://cpan/authors/id/T/TY/TYEMQ/${P}.tar.gz"
LICENSE="|| ( Artistic GPL-2 )"
IUSE=""
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

DEPEND="app-arch/unzip
	dev-lang/perl"

SRC_TEST="do"
