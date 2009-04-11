# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/perltidy/perltidy-20071205.ebuild,v 1.8 2009/03/18 07:32:07 josejx Exp $

EAPI=2

MY_PN=Perl-Tidy
MY_P=${MY_PN}-${PV}
MODULE_AUTHOR=SHANCOCK
inherit perl-module

DESCRIPTION="Perl script indenter and beautifier."
HOMEPAGE="http://perltidy.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
mydoc="examples/*"

pkg_postinst() {
	elog "Example scripts can be found in /usr/share/doc/${PF}"
}
