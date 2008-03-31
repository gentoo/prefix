# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gtk-doc-am/gtk-doc-am-1.10.ebuild,v 1.2 2008/03/24 15:45:05 dang Exp $

EAPI="prefix"

MY_PN="gtk-doc"
MY_P=${MY_PN}-${PV}
DESCRIPTION="Automake files from gtk-doc"
HOMEPAGE="http://www.gtk.org/gtk-doc/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-freebsd"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	!<=dev-utils/gtk-doc-1.10"

S=${WORKDIR}/${MY_P}

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README TODO"

src_compile() {
	mv gtk-doc.m4 gtk-doc-${PV}.m4
}

src_install() {
	insinto /usr/share/aclocal
	doins gtk-doc-${PV}.m4
}
