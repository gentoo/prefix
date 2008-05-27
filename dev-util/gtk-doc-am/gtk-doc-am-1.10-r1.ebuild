# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gtk-doc-am/gtk-doc-am-1.10-r1.ebuild,v 1.6 2008/05/26 17:21:50 leio Exp $

EAPI="prefix"

MY_PN="gtk-doc"
MY_P=${MY_PN}-${PV}
DESCRIPTION="Automake files from gtk-doc"
HOMEPAGE="http://www.gtk.org/gtk-doc/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	!<=dev-util/gtk-doc-1.10"

S=${WORKDIR}/${MY_P}

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README TODO"

src_compile() {
	:
}

src_install() {
	insinto /usr/share/aclocal
	doins gtk-doc.m4
}
