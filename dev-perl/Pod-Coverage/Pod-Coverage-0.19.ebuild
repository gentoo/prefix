# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pod-Coverage/Pod-Coverage-0.19.ebuild,v 1.3 2007/12/11 09:52:58 vapier Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Checks if the documentation of a module is comprehensive"
HOMEPAGE="http://search.cpan.org/~rclamp/"
SRC_URI="mirror://cpan/authors/id/R/RC/RCLAMP/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos"
IUSE="test"
SRC_TEST="do"

DEPEND=">=dev-perl/module-build-0.28
	dev-perl/ExtUtils-CBuilder
	>=virtual/perl-PodParser-1.13
	>=dev-perl/Devel-Symdump-2.01
	dev-lang/perl
	test? ( dev-perl/Test-Pod )"
