# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/yaml/yaml-0.65.ebuild,v 1.10 2007/11/10 19:26:15 drac Exp $

EAPI="prefix"

inherit perl-module

MY_P="YAML-${PV}"
S=${WORKDIR}/${MY_P}
DESCRIPTION="YAML Ain't Markup Language (tm)"
HOMEPAGE="http://search.cpan.org/search?query=${PN}"
SRC_URI="mirror://cpan/authors/id/I/IN/INGY/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

src_compile() {
	echo "" | perl-module_src_compile
}

DEPEND="dev-lang/perl"
