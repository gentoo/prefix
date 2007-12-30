# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Error/Error-0.17.008.ebuild,v 1.11 2007/12/29 10:39:31 welp Exp $

EAPI="prefix"

inherit versionator perl-module

MY_PV="$(delete_version_separator 2)"
MY_P="${PN}-${MY_PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Error/exception handling in an OO-ish way"
HOMEPAGE="http://www.cpan.org/modules/by-module/Error/"
SRC_URI="mirror://cpan/authors/id/S/SH/SHLOMIF/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl
		dev-perl/module-build"
RDEPEND="dev-lang/perl"

SRC_TEST="do"
