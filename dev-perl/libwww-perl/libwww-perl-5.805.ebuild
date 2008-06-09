# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/libwww-perl/libwww-perl-5.805.ebuild,v 1.14 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A collection of Perl Modules for the WWW"
SRC_URI="mirror://cpan/authors/id/G/GA/GAAS/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~gaas/${P}/"
IUSE="ssl"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND="virtual/perl-libnet
	>=dev-perl/HTML-Parser-3.34
	>=dev-perl/URI-1.10
	>=virtual/perl-Digest-MD5-2.12
	dev-perl/HTML-Tree
	>=virtual/perl-MIME-Base64-2.12
	>=dev-perl/Compress-Zlib-1.10
	ssl? ( dev-perl/Crypt-SSLeay )
	dev-lang/perl"

src_compile() {
	echo "y" | perl-module_src_compile
}

src_install() {
	perl-module_src_install

	touch "${T}"/lowercase
	if [[ ! -f ${T}/LOWERCASE ]] ; then
		# most OSX users are on a case-INsensitive filesystem, so don't install
		# these, as in particular HEAD will collide with head (coreutils)
		# this also applies for interix (windows underneath)
		dosym /usr/bin/lwp-request /usr/bin/GET
		dosym /usr/bin/lwp-request /usr/bin/POST
		dosym /usr/bin/lwp-request /usr/bin/HEAD
	fi
}
