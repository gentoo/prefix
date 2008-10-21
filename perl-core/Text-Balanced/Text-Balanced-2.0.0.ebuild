# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Text-Balanced/Text-Balanced-2.0.0.ebuild,v 1.15 2008/03/28 07:09:56 jer Exp $

EAPI="prefix"

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

DEPEND="dev-lang/perl
	dev-perl/version
	>=dev-perl/module-build-0.28"
