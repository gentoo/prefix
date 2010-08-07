# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-menus/gnome-menus-2.30.2-r1.ebuild,v 1.4 2010/08/01 11:33:14 fauli Exp $

EAPI="2"
inherit eutils gnome2 python

DESCRIPTION="The GNOME menu system, implementing the F.D.O cross-desktop spec"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug python"

RDEPEND=">=dev-libs/glib-2.18.0
	python? (
		>=virtual/python-2.4.4-r5
		dev-python/pygtk )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.40"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	# Do NOT compile with --disable-debug/--enable-debug=no
	# It disables api usage checks
	if ! use debug ; then
		G2CONF="${G2CONF} --enable-debug=minimum"
	fi

	G2CONF="${G2CONF} \
		$(use_enable python) \
		--disable-static \
		--disable-introspection"
}

src_prepare() {
	gnome2_src_prepare

	# Don't show KDE standalone settings desktop files in GNOME others menu
	epatch "${FILESDIR}/${PN}-2.18.3-ignore_kde_standalone.patch"

	# Respect XDG_MENU_PREFIX when writing user menu file, bug #291279
	epatch "${FILESDIR}/${P}-XDG_MENU_PREFIX-fix.patch"

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed failed"

	# disable pyc compiling
	mv py-compile py-compile-disabled
	ln -s $(type -P true) py-compile
}

src_install() {
	gnome2_src_install

	find "${ED}" -name "*.la" -delete || die "remove of la files failed"

	# Prefix menu, bug #256614
	mv "${ED}"/etc/xdg/menus/applications.menu \
		"${ED}"/etc/xdg/menus/gnome-applications.menu || die "menu move failed"

	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/10-xdg-menu-gnome" || die "doexe failed"
}

pkg_postinst() {
	gnome2_pkg_postinst
	if use python; then
		python_need_rebuild
		python_mod_optimize $(python_get_sitedir)/GMenuSimpleEditor
	fi

	ewarn "Due to bug #256614, you might lose icons in applications menus."
	ewarn "If you use a login manager, please re-select your session."
	ewarn "If you use startx and have no .xinitrc, just export XSESSION=Gnome."
	ewarn "If you use startx and have .xinitrc, export XDG_MENU_PREFIX=gnome-."
}

pkg_postrm() {
	gnome2_pkg_postrm
	if use python; then
		python_mod_cleanup $(python_get_sitedir)/GMenuSimpleEditor
	fi
}
