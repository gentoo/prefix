# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/kdoc/kdoc-2.0_alpha54.ebuild,v 1.14 2004/06/25 02:38:23 agriffis Exp $

EAPI="prefix"

IUSE=""
MY_P=${P/_alph/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="KDE/QT documentation processing/generation tools"
HOMEPAGE="http://www.ph.unimelb.edu.au/~ssk/kde/kdoc/"
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND="dev-lang/perl"

src_compile() {
	export KDEDIR=""
	export QTDIR=""
	econf || die "econf failed"
	emake || die
}

src_install() {
	einstall
}
