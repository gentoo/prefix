# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Find-Rule/File-Find-Rule-0.30.ebuild,v 1.13 2007/05/05 14:02:47 ian Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Alternative interface to File::Find"
SRC_URI="mirror://cpan/authors/id/R/RC/RCLAMP/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/R/RC/RCLAMP/File-Find-Rule-${PV}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="virtual/perl-Test-Simple
	virtual/perl-File-Spec
	dev-perl/Number-Compare
	dev-perl/Text-Glob
	>=dev-perl/module-build-0.28
	dev-lang/perl"
