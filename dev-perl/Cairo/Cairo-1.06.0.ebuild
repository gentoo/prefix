# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Cairo/Cairo-1.06.0.ebuild,v 1.6 2008/06/13 09:32:04 jer Exp $

inherit perl-module versionator

MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Perl interface to the cairo library"
HOMEPAGE="http://search.cpan.org/dist/Cairo/"
SRC_URI="mirror://cpan/authors/id/T/TS/TSCH/${MY_P}.tar.gz"

IUSE="test"
SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"

SRC_TEST="do"

RDEPEND=">=x11-libs/cairo-1.0.0"
DEPEND="${RDEPEND}
	>=dev-perl/extutils-depends-0.205
	>=dev-perl/extutils-pkgconfig-1.07
	test? ( dev-perl/Test-Number-Delta )"
