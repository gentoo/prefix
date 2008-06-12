# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Error/Error-0.17.012.ebuild,v 1.1 2008/04/23 11:23:37 tove Exp $

EAPI="prefix"

inherit versionator perl-module

MY_PV="$(delete_version_separator 2)"
MY_P="${PN}-${MY_PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Error/exception handling in an OO-ish way"
HOMEPAGE="http://search.cpan.org/dist/Error/"
SRC_URI="mirror://cpan/authors/id/S/SH/SHLOMIF/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="test"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	dev-perl/module-build
	test? ( >=dev-perl/Test-Pod-1.14
		>=dev-perl/Test-Pod-Coverage-1.04 )"

SRC_TEST="do"
