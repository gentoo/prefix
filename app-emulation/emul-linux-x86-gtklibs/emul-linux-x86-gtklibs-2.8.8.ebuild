# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-gtklibs/emul-linux-x86-gtklibs-2.8.8.ebuild,v 1.6 2006/07/30 08:56:21 herbs Exp $

EAPI="prefix"

DESCRIPTION="Gtk+ 1/2 for emulation of 32bit x86 on amd64"
SRC_URI="mirror://gentoo/${P}.tar.bz2
		http://dev.gentoo.org/~herbs/emul/${P}.tar.bz2"
HOMEPAGE="http://www.gentoo.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="-* amd64"
IUSE="qt3"

S="${WORKDIR}"

RDEPEND=">=app-emulation/emul-linux-x86-xlibs-2.0
	>=app-emulation/emul-linux-x86-baselibs-2.5
	qt3? ( >=app-emulation/emul-linux-x86-qtlibs-3.4.4 )"

RESTRICT="nostrip"

src_install() {
	# Avoid dep on qtlibs if qt support not required
	use !qt3 && rm -f "${WORKDIR}/emul/linux/x86/usr/lib/gtk-2.0/2.4.0/engines/libqtengine.so"

	dodir /
	cp -RPvf "${WORKDIR}"/* "${ED}"/

	doenvd "${FILESDIR}"/50emul-linux-x86-gtklibs
}
