# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gtk-engines.eclass,v 1.36 2007/03/26 20:19:22 genstef Exp $

# IMPORTANT:
# This eclass is deprecated and should not be used in new ebuilds.

#
# The gtk-engines eclass is inherited by all gtk-engines-* ebuilds.
#
# Please note that Gtk engines are special packages that mainly provide
# common libraries for Gtk themes, and there is a special meta-package
# that have what you're probably looking for: gtk-themes.
#
# If you want themes to make your GTK 2 apps look pretty, you can do
# something like the following, and everything will be taken care of:
#
#   emerge gtk-themes
#
# If themes for GTK 1 programs is what you're looking for, then something
# like this should help you:
#
#   emerge =gtk-themes-1*

inherit eutils


[ -n "$DEBUG" ] && einfo "Entering gtk-engines.eclass"

[ -z "$DESCRIPTION" ] && DESCRIPTION="Based on the gtk-engines eclass"
[ -z "$HOMEPAGE" ]    && HOMEPAGE="http://www.gnome.org/"
[ -z "$LICENSE" ]     && LICENSE="GPL-2"

KEYWORDS="x86 ppc alpha sparc hppa amd64"

DEPEND=""

case "${SLOT}" in
	"1" )
		DEPEND="${DEPEND} =x11-libs/gtk+-1.2*" ;;
	"2" )
		DEPEND="${DEPEND} >=x11-libs/gtk+-2" ;;
	* )
		DEPEND="${DEPEND} x11-libs/gtk+" ;;
esac

[ -n "$DEBUG" ] && einfo "SLOT is ${SLOT}"

MY_PN="${PN}"
INSTALL_FONTS=0
ENGINE=${PN/gtk-engines-/}

[ -n "$DEBUG" ] && einfo "ENGINE is ${ENGINE}"

case "${ENGINE}" in
	"cleanice" )
		[ "$SLOT" -eq "2" ] && MY_PN="gtk-engines-cleanice2" ;;

	"crux" )
		MY_PN="crux" ;;

	"eazel" )
		MY_PN="eazel-engine" ;;

	"flat" )
		[ "$SLOT" -eq "2" ] && MY_PN="gtk-flat-theme-2.0" ;;

	"geramik" )
		MY_PN="3952-Geramik" ;;

	"lighthouseblue" )
		MY_PN="lighthouseblue" ;;

	"metal" | "notif" | "pixbuf" | "pixmap" | "raleigh" | "redmond95" )
		MY_PN="gtk-engines"
		if [ "$SLOT" -eq "2" ]
		then
			DEPEND="${DEPEND} >=dev-util/pkgconfig-0.12.0"

			# Do _NOT_ strip symbols in the build! Need both lines for Portage
			# 1.8.9+
			DEBUG="yes"
			RESTRICT="nostrip"
			# force debug information
			CFLAGS="${CFLAGS} -g"
			CXXFLAGS="${CXXFLAGS} -g"

		else
			DEPEND="${DEPEND} >=media-libs/imlib-1.8"
		fi
		;;

	"mist" )
		MY_PN="GTK-mist-engine" ;;

	"thinice" )
		[ "$SLOT" -eq "2" ] && MY_PN="gtk-thinice-engine" ;;

	"xenophilia" )
		MY_PN="xenophilia"
		INSTALL_FONTS=1
		;;

	"xfce" )
		MY_PN="gtk-xfce-engine" ;;
esac

MY_P="${MY_PN}-${PV}"

[ -n "$DEBUG" ] && einfo "MY_P is ${MY_P}"

if [ "X${ENGINE}" = "Xthinice" ] && [ "$SLOT" -eq "2" ]
then
	SRC_URI="http://thinice.sourceforge.net/${MY_P}.tar.gz"

elif [ "X${ENGINE}" = "Xmist" ]
then
	SRC_URI="http://ftp.gnome.org/pub/GNOME/teams/art.gnome.org/themes/gtk2/${MY_P}.tar.gz"

elif [ "X${ENGINE}" = "Xflat" ] && [ "$SLOT" -eq "2" ]
then
	SRC_URI="http://download.freshmeat.net/themes/gtk2flat/gtk2flat-default.tar.gz"

elif [ "X${ENGINE}" = "Xgeramik" ]
then
	SRC_URI="http://www.kde-look.org/content/files/${MY_P}.tar.gz"

elif [ "X${ENGINE}" = "Xxfce" ]
then
	SRC_URI="mirror://sourceforge/xfce/${MY_P}.tar.gz"

elif [ "X${ENGINE}" = "Xlighthouseblue" ]
then
	SRC_URI="mirror://sourceforge/lighthouseblue/${MY_P}.tar.gz"

elif [ "X${ENGINE}" = "Xcrux" ]
then
	PVP=(${PV//[-\._]/ })
	SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

elif [ "X${MY_PN}" = "Xgtk-engines" ] && [ "$SLOT" -eq "2" ]
then
	PVP=(${PV//[-\._]/ })
	SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

else
	SRC_PATH="${MY_PN:0:1}/${MY_PN}/${MY_PN}_${PV}.orig.tar.gz"
	SRC_URI="http://ftp.debian.org/debian/pool/main/$SRC_PATH"
fi

[ -n "$DEBUG" ] && einfo "SRC_URI is ${SRC_URI}"

gtk-engines_src_unpack() {
	unpack ${A}

	[ -f "${FILESDIR}/${P}-gentoo.diff" ] && \
		patch -p0 < ${FILESDIR}/${P}-gentoo.diff

	MY_DIR=`ls -t ${WORKDIR} | head -n 1`

	mv $MY_DIR $S
}

gtk-engines_src_compile() {
	econf || die "./configure failed"

	[ "X${MY_PN}" = "Xgtk-engines" ] && cd ${ENGINE}

	emake || die "Compilation failed"
}

gtk-engines_src_install() {
	[ "X${MY_PN}" = "Xgtk-engines" ] && cd ${ENGINE}

	# Some corrections to misc files
	if [ "X${ENGINE}" = "Xxenophilia" ]
	then
		dodir /usr/X11R6/$(get_libdir)/X11/fonts/misc

		mv fonts/Makefile fonts/Makefile.orig
		sed -e 's:/usr:${D}/usr:' \
			-e 's:local:misc:' \
			-e '7,8d' \
			fonts/Makefile.orig > fonts/Makefile || die
		rm fonts/Makefile.orig
	fi

	einstall \
		THEME_DIR=${D}/usr/share/themes \
		ENGINE_DIR=${D}/usr/$(get_libdir)/gtk/themes/engines \
		|| die "Installation failed"

	# Remove unwanted stuff, since some engines include GTK-1 and GTK-2
	# support.
	if [ "X${ENGINE}" = "Xmist" ]
	then
		if [ "$SLOT" -eq "2" ]
		then
			rm -rf ${D}/usr/$(get_libdir)/gtk ${D}/usr/share/themes/Mist/gtk
		else
			rm -rf ${D}/usr/$(get_libdir)/gtk-2.0 ${D}/usr/share/themes/Mist/gtk-2.0
		fi

		rm -rf ${D}/usr/share/themes/Mist/metacity-1

	elif [ "X${ENGINE}" = "Xgeramik" ]
	then
		if [ "$SLOT" -eq "2" ]
		then
			mv ${D}/usr/share/themes/Geramik/gtk/*png \
				${D}/usr/share/themes/Geramik/gtk-2.0
			mv ${D}/usr/share/themes/Geramik/gtk-2.0/gtkrc-2.0 \
				${D}/usr/share/themes/Geramik/gtk-2.0/gtkrc

			rm -rf ${D}/usr/$(get_libdir)/gtk ${D}/usr/share/themes/Geramik/gtk
		else
			rm -rf ${D}/usr/$(get_libdir)/gtk-2.0 ${D}/usr/share/themes/Geramik/gtk-2.0
		fi

	elif [ "X${ENGINE}" = "Xlighthouseblue" ]
	then
		if [ "$SLOT" -eq "2" ]
		then
			rm -rf ${D}/usr/$(get_libdir)/gtk ${D}/usr/share/themes/LighthouseBlue/gtk
		else
			rm -rf \
				${D}/usr/$(get_libdir)/gtk-2.0 \
				${D}/usr/share/themes/LighthouseBlue/gtk-2.0
		fi
	fi

	for doc in AUTHORS BUGS ChangeLog CONFIGURATION COPYING CUSTOMIZATION \
		NEWS README THANKS TODO
	do
		[ -s $doc ] && dodoc $doc
	done
}

gtk-engines_pkg_postinst() {
	if [ "$INSTALL_FONTS" -ne 0 ]
	then
		echo ">>> Updating X fonts..."
		mkfontdir /usr/X11R6/$(get_libdir)/X11/fonts/misc
		xset fp rehash || fonts_notice
	fi
}

gtk-engines_pkg_postrm() {
	if [ "$INSTALL_FONTS" -ne 0 ]
	then
		echo ">>> Updating X fonts..."
		mkfontdir /usr/X11R6/$(get_libdir)/X11/fonts/misc
		xset fp rehash || fonts_notice
	fi
}

fonts_notice() {
	einfo "We can't reset the font path at the moment. You might want"
	einfo "to run the following command manually:"
	einfo ""
	einfo "  xset fp rehash"
}

EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
