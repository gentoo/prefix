# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Text-Balanced/Text-Balanced-2.0.0.ebuild,v 1.17 2009/05/12 13:01:31 aballier Exp $

inherit perl-module

MY_P="${PN}-v${PV}"
S=${WORKDIR}/${MY_P}
DESCRIPTION="Extract balanced-delimiter substrings"
HOMEPAGE="http://search.cpan.org/~dconway"
SRC_URI="mirror://cpan/authors/id/D/DC/DCONWAY/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="dev-lang/perl
	virtual/perl-version"
DEPEND="${RDEPEND}
	>=virtual/perl-Module-Build-0.28"
