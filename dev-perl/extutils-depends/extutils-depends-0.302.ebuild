# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/extutils-depends/extutils-depends-0.302.ebuild,v 1.7 2009/09/27 15:03:31 ranger Exp $

EAPI=2

MODULE_AUTHOR=TSCH
MY_PN=ExtUtils-Depends
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}
inherit perl-module

DESCRIPTION="Easily build XS extensions that depend on XS extensions"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

SRC_TEST="do"
