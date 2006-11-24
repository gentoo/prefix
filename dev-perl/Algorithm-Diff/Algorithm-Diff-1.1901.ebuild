# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Algorithm-Diff/Algorithm-Diff-1.1901.ebuild,v 1.12 2006/09/16 20:23:03 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Algorithm::Diff - Compute intelligent differences between two files / lists"
HOMEPAGE="http://search.cpan.org/~tyemq/${P}/"
SRC_URI="mirror://cpan/authors/id/T/TY/TYEMQ/Algorithm-Diff-1.1901.zip"
LICENSE="|| ( Artistic GPL-2 )"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND="app-arch/unzip
	dev-lang/perl"
RDEPEND="${DEPEND}"

SRC_TEST="do"
