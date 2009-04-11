# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-SSLeay/Net-SSLeay-1.35.ebuild,v 1.8 2009/03/21 01:48:14 jer Exp $

MODULE_AUTHOR=FLORA
inherit perl-module multilib

DESCRIPTION="Net::SSLeay module for perl"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="dev-libs/openssl
	dev-lang/perl"
DEPEND="${RDEPEND}"
#	test? ( dev-perl/Test-Exception
#		dev-perl/Test-Warn
#		dev-perl/Test-NoWarnings )"

#SRC_TEST=do

export OPTIMIZE="$CFLAGS"
export OPENSSL_PREFIX=${EPREFIX}/usr

myconf="${myconf} ${EPREFIX}/usr"

src_unpack() {
	unpack ${A}
	if [ $(get_libdir) != "lib" ] ; then
		sed -i -e "s:openssl_path/lib:openssl_path/$(get_libdir):" \
		"${S}"/Makefile.PL || die
	fi
}
