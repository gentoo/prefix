# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/abiword/abiword-2.6.8.ebuild,v 1.6 2010/03/31 18:47:09 armin76 Exp $

EAPI="2"

inherit alternatives eutils gnome2 versionator

MY_MAJORV=$(get_version_component_range 1-2)

DESCRIPTION="Fully featured yet light and fast cross platform word processor"
HOMEPAGE="http://www.abisource.com/"
SRC_URI="http://www.abisource.com/downloads/${PN}/${PV}/source/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug gnome spell xml"

# FIXME: gsf could probably be conditional

# Pango version so it always has X use flag
RDEPEND="dev-libs/popt
	sys-libs/zlib
	>=dev-libs/glib-2
	>=x11-libs/gtk+-2.6
	x11-libs/libXft
	>=x11-libs/pango-1.24.2[X]
	>=gnome-base/libglade-2
	>=gnome-base/libgnomeprint-2.2
	>=gnome-base/libgnomeprintui-2.2
	>=x11-libs/goffice-0.4:0.4
	>=media-libs/libpng-1.2
	>=media-libs/fontconfig-2.1
	>=media-libs/freetype-2.1
	>=app-text/wv-1.2
	>=dev-libs/fribidi-0.10.4
	xml? ( >=dev-libs/libxml2-2.4.10 )
	!xml? ( dev-libs/expat )
	spell? ( >=app-text/enchant-1.2 )
	gnome?	(
		>=gnome-base/libbonobo-2
		>=gnome-base/libgnomeui-2.2
		>=gnome-extra/gucharmap-1.4
		>=gnome-base/gnome-vfs-2.2 )
	>=gnome-extra/libgsf-1.12.0"

DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9"

# FIXME: --enable-libabiword fails to compile

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable debug symbols)
		$(use_enable gnome gnomeui)
		$(use_enable gnome gucharmap)
		$(use_enable gnome gnomevfs)
		$(use_enable spell spellcheck)
		$(use_with xml libxml2)
		$(use_with !xml expat)
		--enable-libabiword
		--enable-printing"
}

src_install() {
	# Install icon to pixmaps, bug #220097
	sed 's:icondir = $(datadir)/icons:icondir = $(datadir)/pixmaps:'	\
		-i GNUmakefile || die "sed 1 failed"

	gnome2_src_install

	sed "s:Exec=abiword:Exec=abiword-${MY_MAJORV}:" \
		-i "${ED}"/usr/share/applications/abiword.desktop || die "sed 2 failed"

	mv "${ED}/usr/bin/abiword" "${ED}/usr/bin/AbiWord-${MY_MAJORV}"
	dosym AbiWord-${MY_MAJORV} /usr/bin/abiword-${MY_MAJORV}

	dodoc *.TXT user/wp/readme.txt
}

pkg_postinst() {
	gnome2_pkg_postinst

	alternatives_auto_makesym "/usr/bin/abiword" "/usr/bin/abiword-[0-9].[0-9]"

	elog "As of version 2.4, all abiword plugins have been moved"
	elog "into a seperate app-office/abiword-plugins package"
	elog "You can install them by running emerge abiword-plugins"
}
