# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SVN-Simple/SVN-Simple-0.27.ebuild,v 1.15 2009/12/10 07:52:15 tove Exp $

EAPI="2"

MODULE_AUTHOR=CLKAO
inherit perl-module

DESCRIPTION="SVN::Simple::Edit - Simple interface to SVN::Delta::Editor"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND=">=dev-util/subversion-0.31[perl]"
DEPEND="${RDEPEND}"
