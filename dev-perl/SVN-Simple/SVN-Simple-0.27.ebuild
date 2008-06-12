# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SVN-Simple/SVN-Simple-0.27.ebuild,v 1.13 2007/07/13 19:20:01 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="SVN::Simple::Edit - Simple interface to SVN::Delta::Editor"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~clkao/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-util/subversion-0.31
	dev-lang/perl"

pkg_setup() {
	if ! built_with_use dev-util/subversion perl; then
		eerror "You need >=dev-util/subversion-0.31 compiled with Perl bindings."
		die "Need Subversion compiled with Perl bindings."
	fi
}
