# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-sports/bygfoot/bygfoot-2.3.2.ebuild,v 1.2 2009/07/31 22:51:44 darkside Exp $

EAPI=2
inherit eutils games

DESCRIPTION="GTK+2 Soccer Management Game"
HOMEPAGE="http://bygfoot.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2
	media-libs/freetype:2
	virtual/libintl"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

src_prepare() {
	sed -i \
		-e 's:$(gnulocaledir):/usr/share/locale:' \
		-e '/PACKAGE_LOCALE_DIR/s:\$(prefix)/\$(DATADIRNAME):/usr/share:' \
		po/Makefile.in.in src/Makefile.in \
		|| die "sed failed"
	sed -i \
		-e "s:/usr/share:${EPREFIX}/usr/share:" \
		po/Makefile.in.in src/Makefile.in \
		|| die "sed failed"
}

src_configure() {
	egamesconf \
		--disable-dependency-tracking \
		--disable-gstreamer
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	esvn_clean "${ED}"
	dodoc AUTHORS ChangeLog README TODO UPDATE
	newicon support_files/pixmaps/bygfoot_icon.png ${PN}.png
	make_desktop_entry ${PN} Bygfoot
	prepgamesdirs
}
