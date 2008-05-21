# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateManip/DateManip-5.44.ebuild,v 1.13 2007/07/10 23:33:33 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Perl date manipulation routines"
HOMEPAGE="http://www.perl.com/CPAN/authors/id/SBECK/DateManip-5.44.readme"
SRC_URI="mirror://cpan/authors/id/S/SB/SBECK/${P}.tar.gz"
SRC_TEST="do"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

mydoc="HISTORY TODO"

DEPEND="dev-lang/perl"
