# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_REPO_URI="http://prefix-launcher.svn.sourceforge.net/svnroot/prefix-launcher/eprefix-bootstrap/trunk"

inherit subversion

DESCRIPTION="bootstrap another standalone Gentoo Prefix instance"
HOMEPAGE="http://sourceforge.net/projects/prefix-launcher/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	newbin eprefix-bootstrap ${PN} || die
	dodoc ChangeLog
}
