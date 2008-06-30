# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Crypt-SSLeay/Crypt-SSLeay-0.57.ebuild,v 1.8 2008/06/07 12:03:12 aballier Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Crypt::SSLeay module for perl"
SRC_URI="mirror://cpan/authors/id/D/DL/DLAND/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~dland/"
IUSE=""
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"

# Disabling tests for now. Opening a port always leads to mixed results for
# folks - bug 59554
# nb. Re-enabled tests, seem to be better written now, keeping an eye on bugs
# for this though.
SRC_TEST="do"

DEPEND="virtual/libc
	>=dev-lang/perl-5
	>=dev-libs/openssl-0.9.7c"
PDEPEND="dev-perl/libwww-perl"

export OPTIMIZE="${CFLAGS}"
myconf="${myconf} --lib=${EPREFIX}/usr ${EPREFIX}/usr"
