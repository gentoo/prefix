# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-murrine/gtk-engines-murrine-0.90.3.ebuild,v 1.2 2009/04/05 12:48:11 jokey Exp $

EAPI=2

MY_P=${P/gtk-engines-//}

DESCRIPTION="Murrine GTK+2 Cairo Engine"
HOMEPAGE="http://www.cimitan.com/murrine/"

THEME_URI="http://www.cimitan.com/murrine/files"
SRC_URI="mirror://gnome/sources/murrine/0.90/${MY_P}.tar.bz2
		 ${THEME_URI}/MurrinaBlu-0.32.tar.gz
		 ${THEME_URI}/MurrinaGilouche.tar.bz2
		 ${THEME_URI}/MurrinaCream.tar.gz
		 ${THEME_URI}/MurrinaVerdeOlivo.tar.bz2
		 ${THEME_URI}/MurrinaCandido.tar.gz
		 ${THEME_URI}/MurrinaAquaIsh.tar.bz2
		 ${THEME_URI}/MurrinaChrome.tar.gz
		 ${THEME_URI}/MurrinaFancyCandy.tar.bz2
		 ${THEME_URI}/MurrinaLoveGray.tar.bz2
		 ${THEME_URI}/MurrineRounded.tar.bz2
		 ${THEME_URI}/MurrinaTango.tar.bz2
		 ${THEME_URI}/MurrinaBlue.tar.bz2
		 ${THEME_URI}/Murrine-Light.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="animation-rtl"

RDEPEND=">=x11-libs/gtk+-2.12"
DEPEND="dev-util/pkgconfig
		${REPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local myconf
	use animation-rtl && myconf="--enable-animation-rtl"
	econf \
		--enable-animation \
		--enable-rgba \
		$myconf || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS TODO

	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r "${WORKDIR}"/Murrin*
}
