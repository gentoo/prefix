# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/set-scalar/set-scalar-1.23.ebuild,v 1.1 2009/01/19 10:10:33 tove Exp $

MODULE_AUTHOR=JHI
MY_PN=Set-Scalar
MY_P=${MY_PN}-${PV}
inherit perl-module

DESCRIPTION="Scalar set operations"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

S=${WORKDIR}/${MY_P}

DEPEND="dev-lang/perl"
RDEPEND=${DEPEND}

SRC_TEST="do"
