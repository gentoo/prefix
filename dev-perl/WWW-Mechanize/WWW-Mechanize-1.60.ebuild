# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/WWW-Mechanize/WWW-Mechanize-1.60.ebuild,v 1.5 2009/09/19 16:30:21 nixnut Exp $

EAPI=2

MODULE_AUTHOR=PETDANCE
inherit perl-module

DESCRIPTION="Handy web browsing in a Perl object"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

# Bug in the tests - improper use of HTTP::Server
SRC_TEST="do"

# configure to run the local tests, but not the ones which access the Internet
myconf="--local --nolive"

RDEPEND="dev-perl/IO-Socket-SSL
	>=dev-perl/libwww-perl-5.829
	>=dev-perl/URI-1.36
	>=dev-perl/HTML-Parser-3.34
	dev-perl/Test-LongString"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Taint
		>=dev-perl/Test-Warn-0.11
		dev-perl/Test-Memory-Cycle )"
#		dev-perl/HTTP-Server-Simple )"

# Remove test until the bug is fixed:
# http://rt.cpan.org/Public/Bug/Display.html?id=41673
src_unpack() {
	perl-module_src_unpack
	mv "${S}"/t/cookies.t{,.disable} || die
	sed -i "/cookies.t/d" "${S}/MANIFEST" || die
}
