# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/chasen/chasen-2.4.2.ebuild,v 1.1 2007/12/31 08:28:58 matsuu Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Japanese Morphological Analysis System, ChaSen"
HOMEPAGE="http://chasen-legacy.sourceforge.jp/"
SRC_URI="mirror://sourceforge.jp//chasen-legacy/26441/${P}.tar.gz"

LICENSE="chasen"
SLOT="0"
# does not compile
KEYWORDS="~sparc-solaris"
IUSE="perl"

DEPEND=">=dev-libs/darts-0.31"
RDEPEND="${DEPEND}
	perl? ( !dev-perl/Text-ChaSen )"
PDEPEND=">=app-dicts/ipadic-2.7.0"

src_compile() {
	econf || die
	emake || die
	if use perl ; then
		cd "${S}"/perl
		perl-module_src_compile
	fi
}

src_install () {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README

	if use perl ; then
		cd "${S}"/perl
		perl-module_src_install
		newdoc README README.perl
	fi
}
