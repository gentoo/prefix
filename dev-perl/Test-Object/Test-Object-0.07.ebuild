# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Object/Test-Object-0.07.ebuild,v 1.3 2007/12/27 13:52:05 ticho Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Thoroughly testing objects via registered handlers"
HOMEPAGE="http://search.cpan.org/dist/${PN}"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl
		virtual/perl-File-Spec
		virtual/perl-Scalar-List-Utils
		virtual/perl-Test-Simple"
