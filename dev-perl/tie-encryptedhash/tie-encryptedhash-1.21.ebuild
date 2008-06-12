# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/tie-encryptedhash/tie-encryptedhash-1.21.ebuild,v 1.16 2007/01/19 17:02:37 mcummings Exp $

EAPI="prefix"

inherit perl-module

MY_P=Tie-EncryptedHash-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Hashes (and objects based on hashes) with encrypting fields."
HOMEPAGE="http://search.cpan.org/~vipul/"
SRC_URI="mirror://cpan/authors/id/V/VI/VIPUL/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-perl/Crypt-Blowfish
	dev-perl/Crypt-DES
	dev-perl/crypt-cbc
	dev-lang/perl"
