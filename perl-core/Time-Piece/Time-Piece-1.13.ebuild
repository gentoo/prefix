# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Time-Piece/Time-Piece-1.13.ebuild,v 1.1 2008/11/02 07:32:11 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=MSERGEANT
inherit perl-module

DESCRIPTION="Object Oriented time objects"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
