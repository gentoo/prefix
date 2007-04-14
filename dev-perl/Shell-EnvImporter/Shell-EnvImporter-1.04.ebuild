# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Shell-EnvImporter/Shell-EnvImporter-1.04.ebuild,v 1.9 2007/04/09 16:27:55 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl extension for importing environment variable changes from external commands or shell scripts"
HOMEPAGE="http://search.cpan.org/~dfaraldo"
SRC_URI="mirror://cpan/authors/id/D/DF/DFARALDO/${P}.tar.gz"

IUSE=""

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND=">=dev-perl/Class-MethodMaker-2
		dev-lang/perl"
