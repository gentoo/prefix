# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Cairo/Cairo-1.06.1.ebuild,v 1.1 2009/06/07 18:36:52 tove Exp $

EAPI=2

inherit versionator
MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}
MODULE_AUTHOR=TSCH
inherit perl-module

DESCRIPTION="Perl interface to the cairo library"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="test"

SRC_TEST="do"

RDEPEND=">=x11-libs/cairo-1.0.0"
DEPEND="${RDEPEND}
	>=dev-perl/extutils-depends-0.205
	>=dev-perl/extutils-pkgconfig-1.07
	test? ( dev-perl/Test-Number-Delta )"
