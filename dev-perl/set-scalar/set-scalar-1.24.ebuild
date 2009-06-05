# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/set-scalar/set-scalar-1.24.ebuild,v 1.1 2009/06/03 17:03:45 tove Exp $

EAPI=2

MODULE_AUTHOR=JHI
MY_PN=Set-Scalar
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}
inherit perl-module

DESCRIPTION="Scalar set operations"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"
