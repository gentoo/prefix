# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Manifest/Test-Manifest-1.21.ebuild,v 1.4 2008/01/13 21:48:48 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Interact with a t/test_manifest file"
SRC_URI="mirror://cpan/authors/id/B/BD/BDFOY/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~bdfoy/${P}/"

IUSE=""
SLOT="0"
LICENSE="Artistic"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"

SRC_TEST="do"

DEPEND="dev-lang/perl"
