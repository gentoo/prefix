# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-themes/gtk-engines-murrine/gtk-engines-murrine-0.53.1-r1.ebuild,v 1.5 2008/07/07 21:55:24 jokey Exp $

inherit eutils autotools

MY_PN="murrine"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Murrine GTK+2 Cairo Engine"

HOMEPAGE="http://www.cimitan.com/murrine/"
URI_PREFIX="http://cimi.netsons.org/media/download_gallery"
SRC_URI="${URI_PREFIX}/${MY_PN}/${MY_P}.tar.bz2 ${URI_PREFIX}/MurrinaFancyCandy.tar.bz2 ${URI_PREFIX}/MurrinaVerdeOlivo.tar.bz2 ${URI_PREFIX}/MurrinaGilouche.tar.bz2 ${URI_PREFIX}/MurrinaLoveGray.tar.bz2 ${URI_PREFIX}/MurrineThemePack.tar.bz2 ${URI_PREFIX}/MurrineXfwm.tar.bz2 http://www.kernow-webhosting.com/~bvc/theme/mcity/Murrine.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "$S"

	# Fix for bug #198815
	epatch "${FILESDIR}/${P}-use-gtk_free.patch"

	eautoreconf # required for interix
}

src_compile() {
	econf --enable-animation || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r "${WORKDIR}"/Murrin*

	dodoc AUTHORS ChangeLog CREDITS
}
