# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/TermReadKey/TermReadKey-2.30.ebuild,v 1.12 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Change terminal modes, and perform non-blocking reads"
HOMEPAGE="http://search.cpan.org/~jstowe/"
SRC_URI="mirror://cpan/authors/id/J/JS/JSTOWE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

mymake="/usr"

DEPEND="dev-lang/perl"
