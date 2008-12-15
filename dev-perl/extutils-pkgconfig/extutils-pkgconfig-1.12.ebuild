# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/extutils-pkgconfig/extutils-pkgconfig-1.12.ebuild,v 1.2 2008/12/13 13:05:37 aballier Exp $

EAPI="prefix"

MODULE_AUTHOR=TSCH
MY_PN=ExtUtils-PkgConfig
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}

inherit perl-module

DESCRIPTION="Simplistic perl interface to pkg-config"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	dev-util/pkgconfig"
RDEPEND="${DEPEND}"

SRC_TEST="do"
