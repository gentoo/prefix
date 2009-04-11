# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/regexp-common/regexp-common-2.122.ebuild,v 1.1 2008/07/22 10:08:11 tove Exp $

MODULE_AUTHOR=ABIGAIL
inherit perl-module

MY_P=Regexp-Common-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Provide commonly requested regular expressions"
HOMEPAGE="http://www.cpan.org/authors/id/A/AB/ABIGAIL/"
SRC_URI="mirror://cpan/authors/id/A/AB/ABIGAIL/${MY_P}.tar.gz"

LICENSE="|| ( Artistic Artistic-2 MIT BSD )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
