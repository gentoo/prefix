# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-dict/xfce4-dict-0.3.0.ebuild,v 1.10 2008/12/05 16:20:27 angelos Exp $

inherit xfce44

xfce44
xfce44_gzipped

DESCRIPTION="A plugin to query a Dict server and other dictionary sources"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="dev-util/intltool"

DOCS="AUTHORS ChangeLog README"

src_unpack() {
	unpack ${A}
	echo panel-plugin/aspell.c >> "${S}"/po/POTFILES.skip
}

pkg_postinst() {
	xfce44_pkg_postinst

	if ! has_version app-text/aspell && ! has_version app-text/ispell \
	&& ! has_version app-text/enchant; then
		echo
		elog "You need a spell check program for spell checking."
		elog "xfce4-dict works with enchant, aspell, ispell or any other spell"
		elog "check program which is compatible with the ispell command"
		elog "The dictionary function will still work without those"
	fi
}

xfce44_goodies_panel_plugin
