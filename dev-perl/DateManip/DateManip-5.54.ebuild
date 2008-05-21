# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateManip/DateManip-5.54.ebuild,v 1.1 2008/05/20 16:06:28 tove Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl date manipulation routines"
HOMEPAGE="http://search.cpan.org/dist/Date-Manip"
SRC_URI="mirror://cpan/authors/id/S/SB/SBECK/Date-Manip-${PV}.tar.gz"
SRC_TEST="do"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	dev-perl/module-build"

S=${WORKDIR}/Date-Manip-${PV}

mydoc="HISTORY TODO"
