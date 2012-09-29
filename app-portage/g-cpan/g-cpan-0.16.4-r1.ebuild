# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/g-cpan/g-cpan-0.16.4-r1.ebuild,v 1.1 2012/06/17 12:49:58 flameeyes Exp $

EAPI=4

inherit perl-module prefix

DESCRIPTION="g-cpan: generate and install CPAN modules using portage"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/g-cpan.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz
		 http://dev.gentoo.org/~robbat2/distfiles/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
		>=dev-perl/yaml-0.60
		dev-perl/Shell-EnvImporter
		dev-perl/Log-Agent"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-misc.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify bin/g-cpan lib/Gentoo/Portage.pm lib/Gentoo/CPAN.pm
}

src_install() {
	perl-module_src_install
	diropts "-m0755"
	dodir "/var/tmp/g-cpan"
	keepdir "/var/tmp/g-cpan"
	dodir "/var/log/g-cpan"
	keepdir "/var/log/g-cpan"
}

pkg_postinst() {
	elog "You may wish to adjust the permissions on /var/tmp/g-cpan"
	elog "if you have users besides root expecting to use g-cpan."
	elog "Please note that some CPAN packages need additional manual"
	elog "parameters or tweaking, due to bugs in their build systems."
}
