# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/File-Spec/File-Spec-3.25.ebuild,v 1.8 2007/11/19 03:45:17 kumba Exp $

EAPI="prefix"

inherit perl-module

MY_P="PathTools-${PV}"

DESCRIPTION="Handling files and directories portably"
HOMEPAGE="http://search.cpan.org/~kwilliams/"
SRC_URI="mirror://cpan/authors/id/K/KW/KWILLIAMS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

RDEPEND="dev-lang/perl
	dev-perl/ExtUtils-CBuilder"
DEPEND="${RDEPEND}
	dev-perl/module-build"

S=${WORKDIR}/${MY_P}

myconf='INSTALLDIRS=vendor'
