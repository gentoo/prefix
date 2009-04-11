# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Time-Piece/Time-Piece-1.13.ebuild,v 1.3 2008/09/30 15:23:45 tove Exp $

MODULE_AUTHOR=MSERGEANT
inherit perl-module

DESCRIPTION="Object Oriented time objects"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
