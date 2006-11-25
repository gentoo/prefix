# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Iconv/Text-Iconv-1.4.ebuild,v 1.15 2006/11/12 05:33:40 vapier Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl interface to the iconv() codeset conversion function"
HOMEPAGE="http://cpan.org/modules/by-module/Text/${P}.readme"
SRC_URI="mirror://cpan/authors/id/M/MP/MPIOTR/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"
