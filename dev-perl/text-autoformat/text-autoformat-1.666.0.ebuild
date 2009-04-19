# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/text-autoformat/text-autoformat-1.666.0.ebuild,v 1.1 2009/04/17 20:52:20 tove Exp $

EAPI=2

MY_PN=Text-Autoformat
MY_P=${MY_PN}-${PV}
MODULE_AUTHOR=DCONWAY
inherit perl-module

DESCRIPTION="Automatic text wrapping and reformatting"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-perl/text-reform-1.11
	virtual/perl-version"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build"

S=${WORKDIR}/${MY_P}
SRC_TEST=do
