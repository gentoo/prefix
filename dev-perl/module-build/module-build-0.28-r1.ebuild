# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/module-build/module-build-0.28-r1.ebuild,v 1.10 2007/01/21 15:49:48 mcummings Exp $

EAPI="prefix"

inherit perl-module

MY_PV=${PV/26.11/2611}
MY_P="Module-Build-${MY_PV}"
S=${WORKDIR}/${MY_P}
DESCRIPTION="Build and install Perl modules"
HOMEPAGE="http://search.cpan.org/~kwilliams/"
SRC_URI="mirror://cpan/authors/id/K/KW/KWILLIAMS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

# Removing these as hard deps. They are listed as recommended in the Build.PL,
# but end up causing a dep loop since they require module-build to be built.
# ~mcummings 06.16.06
PDEPEND=">=dev-perl/ExtUtils-CBuilder-0.15
	>=dev-perl/extutils-parsexs-1.02"

DEPEND="dev-lang/perl
	dev-perl/yaml
	>=dev-perl/Archive-Tar-1.09"

SRC_TEST="do"
