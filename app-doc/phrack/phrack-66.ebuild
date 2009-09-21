# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/phrack/phrack-66.ebuild,v 1.2 2009/09/17 07:48:29 ulm Exp $

MY_P=${PN}${PV}
DESCRIPTION="...a Hacker magazine by the community, for the community...."
HOMEPAGE="http://www.phrack.org/"
SRC_URI="http://www.phrack.org/archives/tgz/${MY_P}.tar.gz"

LICENSE="phrack"
SLOT="${PV}"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

S=${WORKDIR}/${MY_P}

src_install() {
	[[ -d ${S} ]] || cd "${WORKDIR}"/*
	insinto /usr/share/doc/${PN}
	doins * || die "doins failed"
	prepalldocs
}
