# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/gentoo-syntax/gentoo-syntax-20050618.ebuild,v 1.3 2005/09/05 04:19:49 j4rg0n Exp $

EAPI="prefix"

inherit eutils vim-plugin

DESCRIPTION="vim plugin: Gentoo Ebuild, Eclass, GLEP, ChangeLog and Portage
Files syntax highlighting, filetype and indent settings"
HOMEPAGE="http://developer.berlios.de/projects/gentoo-syntax"
LICENSE="vim"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sparc x86 ~ppc-macos"
SRC_URI="http://dev.gentoo.org/~ka0ttic/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2"

IUSE="ignore-glep31"
VIM_PLUGIN_HELPFILES="gentoo-syntax"
VIM_PLUGIN_MESSAGES="filetype"

src_unpack() {
	unpack ${A}
	cd ${S}

	if use ignore-glep31 ; then
		for f in ftplugin/*.vim ; do
			ebegin "Removing UTF-8 rules from ${f} ..."
			sed -i -e 's~\(setlocal fileencoding=utf-8\)~" \1~' ${f} \
				|| die "waah! bad sed voodoo. need more goats."
			eend $?
		done
	fi
}

pkg_postinst() {
	vim-plugin_pkg_postinst
	if use ignore-glep31 1>/dev/null ; then
		ewarn "You have chosen to disable the rules which ensure GLEP 31"
		ewarn "compliance. When editing ebuilds, please make sure you get"
		ewarn "the character set correct."
	else
		einfo "Note for developers and anyone else who edits ebuilds:"
		einfo "    This release of gentoo-syntax now contains filetype rules to set"
		einfo "    fileencoding for ebuilds and ChangeLogs to utf-8 as per GLEP 31."
		einfo "    If you find this feature breaks things, please submit a bug and"
		einfo "    assign it to vim@gentoo.org. You can use the 'ignore-glep31' USE"
		einfo "    flag to remove these rules."
	fi
	echo
	epause 5
}

