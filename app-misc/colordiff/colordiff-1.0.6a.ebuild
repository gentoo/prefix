# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/colordiff/colordiff-1.0.6a.ebuild,v 1.1 2007/06/21 23:25:44 dberkholz Exp $

EAPI="prefix"

DESCRIPTION="Colorizes output of diff"
HOMEPAGE="http://colordiff.sourceforge.net/"
#SRC_URI="mirror://sourceforge/colordiff/${P}.tar.gz"
# Hasn't been copied to mirrors yet
SRC_URI="http://${PN}.sourceforge.net/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="sys-apps/diffutils"

src_unpack() {
	unpack $A
	cd $S
	# option name is wrong in configs #152141
	sed -i 's/\(color_patch\)es/\1/g' colordiffrc*
}

src_compile() {
	true
}

src_install() {
	newbin colordiff.pl colordiff || die "failed to install colordiff"
	newbin cdiff.sh cdiff || die "failed to install cdiff"
	insinto /etc
	doins colordiffrc colordiffrc-lightbg || die "failed to install colordiffrc files"
	dodoc BUGS CHANGES README TODO
	doman colordiff.1
}
