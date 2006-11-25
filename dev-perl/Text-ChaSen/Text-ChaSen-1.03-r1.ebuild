# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-ChaSen/Text-ChaSen-1.03-r1.ebuild,v 1.8 2006/08/06 00:20:34 mcummings Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="Chasen library module for Perl."
SRC_URI="http://www.daionet.gr.jp/~knok/chasen/${P}.tar.gz
	http://www.daionet.gr.jp/~knok/chasen/ChaSen.pm-1.03-pod-fix.diff"
HOMEPAGE="http://www.daionet.gr.jp/~knok/chasen/"

SLOT="0"
LICENSE="chasen"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=app-text/chasen-2.2.9
	dev-lang/perl"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${DISTDIR}/ChaSen.pm-1.03-pod-fix.diff
	sed -i -e '5a"LD" => "g++",' Makefile.PL || die
}


