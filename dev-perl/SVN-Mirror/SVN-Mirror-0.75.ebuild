# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SVN-Mirror/SVN-Mirror-0.75.ebuild,v 1.1 2008/09/13 08:23:53 tove Exp $

MODULE_AUTHOR=CLKAO
inherit perl-module eutils

DESCRIPTION="SVN::Mirror - Mirror remote repositories to local subversion repository"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-util/subversion-1.1.3
	>=dev-perl/URI-1.34
	>=dev-perl/TermReadKey-2.21
	>=dev-perl/SVN-Simple-0.26
	dev-perl/Data-UUID
	dev-perl/Class-Accessor
	dev-perl/TimeDate
	dev-perl/File-chdir
	dev-lang/perl"

SRC_TEST=do

pkg_setup() {
	if ! built_with_use dev-util/subversion perl ; then
		eerror "You need subversion compiled with Perl bindings."
		eerror "USE=\"perl\" emerge subversion"
		die "Need Subversion compiled with Perl bindings."
	fi
}
