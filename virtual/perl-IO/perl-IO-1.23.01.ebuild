# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-IO/perl-IO-1.23.01.ebuild,v 1.8 2009/01/09 21:26:07 josejx Exp $

EAPI="prefix"

inherit versionator

MY_PV=$(delete_version_separator 2)
DESCRIPTION="Virtual for IO"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE=""
DEPEND=""
RDEPEND="~perl-core/IO-${PV}"
