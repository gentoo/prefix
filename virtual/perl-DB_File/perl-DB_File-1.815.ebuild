# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-DB_File/perl-DB_File-1.815.ebuild,v 1.7 2007/07/04 18:04:56 armin76 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Virtual for DB_File"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-macos"

IUSE=""
DEPEND=""
RDEPEND="~perl-core/DB_File-${PV}"

pkg_setup() {
	if ! has_version "~perl-core/DB_File-${PV}" && ! built_with_use dev-lang/perl berkdb ; then
		die "You must build perl with USE=\"berkdb\" or install perl-core/DB_File-${PV}"
	fi
}
