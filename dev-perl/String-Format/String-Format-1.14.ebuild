# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/String-Format/String-Format-1.14.ebuild,v 1.7 2007/07/10 23:33:33 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="sprintf-like string formatting capabilities with arbitrary format definitions"
HOMEPAGE="http://search.cpan.org/~darren/"
SRC_URI="mirror://cpan/authors/id/D/DA/DARREN/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
