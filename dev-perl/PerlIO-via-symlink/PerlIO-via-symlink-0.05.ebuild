# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PerlIO-via-symlink/PerlIO-via-symlink-0.05.ebuild,v 1.11 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="PerlIO::via::symlink -  PerlIO layer for symlinks"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~clkao/"

SLOT="0"
LICENSE="Artistic"
SRC_TEST="do"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"
