# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/igal/igal-2.0.ebuild,v 1.6 2009/03/23 12:41:06 tcunha Exp $

EAPI=2

MY_P=${PN}2-${PV}

DESCRIPTION="Static HTML image gallery generator"
HOMEPAGE="http://igal.trexler.at"
SRC_URI="http://${PN}.trexler.at/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="dev-lang/perl
	media-libs/jpeg
	media-gfx/imagemagick"
DEPEND=""

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -e "s:/usr/local/lib/igal2:/usr/share/igal2:g" \
		-i igal2 -i igal2.1 || die "sed failed."
	sed -i -e "s:/usr/local/bin/igal2:/usr/bin/igal2:" \
		utilities/igal2.sh || die "sed failed."
}

src_compile() {
	true
}

src_install() {
	dobin igal2 utilities/igal2.sh || die "dobin failed."
	dosym igal2 /usr/bin/igal || die "dosym failed."
	doman igal2.1
	dodoc ChangeLog README
	insinto /usr/share/igal2
	doins *.html tile.png igal2.css || die "doins failed."
}
