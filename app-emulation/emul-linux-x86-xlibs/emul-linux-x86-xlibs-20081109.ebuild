# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-xlibs/emul-linux-x86-xlibs-20081109.ebuild,v 1.6 2009/12/30 19:53:25 pacho Exp $

inherit emul-linux-x86

LICENSE="FTL GPL-2 LGPL-2 glut MIT MOTIF"
KEYWORDS="~amd64-linux"
IUSE="opengl"

DEPEND="opengl? ( app-admin/eselect-opengl )"
RDEPEND="=app-emulation/emul-linux-x86-baselibs-${PV}
	x11-libs/libX11
	opengl? ( media-libs/mesa )"

QA_DT_HASH="usr/lib32/.*"

src_unpack() {
	emul-linux-x86_src_unpack
	rm -f "${S}/usr/lib32/libGL.so"
}

pkg_postinst() {
	#update GL symlinks
	use opengl && eselect opengl set --use-old
}

