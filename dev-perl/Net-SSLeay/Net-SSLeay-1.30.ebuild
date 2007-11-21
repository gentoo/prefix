# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-SSLeay/Net-SSLeay-1.30.ebuild,v 1.10 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module multilib

MY_P=${PN/-/_}.pm-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Net::SSLeay module for perl"
HOMEPAGE="http://search.cpan.org/~flora/"
SRC_URI="mirror://cpan/authors/id/F/FL/FLORA/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE=""

DEPEND="dev-libs/openssl
	dev-lang/perl"

export OPTIMIZE="$CFLAGS"

myconf="${myconf} ${EPREFIX}/usr"

src_unpack() {
	unpack ${A}
	if [ $(get_libdir) != "lib" ] ; then
		sed -i -e "s:openssl_path/lib:openssl_path/$(get_libdir):" \
		${S}/Makefile.PL || die
	fi
}
