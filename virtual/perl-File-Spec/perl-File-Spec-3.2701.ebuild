# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-File-Spec/perl-File-Spec-3.2701.ebuild,v 1.2 2008/07/15 18:42:48 armin76 Exp $

EAPI="prefix"

DESCRIPTION="Virtual for File-Spec"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

IUSE=""
DEPEND=""
RDEPEND="|| ( ~perl-core/File-Spec-${PV} >=dev-lang/perl-5.10 )"
