# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-xlibs/emul-linux-x86-xlibs-20071128-r2.ebuild,v 1.1 2007/11/30 22:04:38 angelos Exp $

EAPI="prefix"

inherit emul-linux-x86

LICENSE="fontconfig FTL GPL-2 LGPL-2 glut libdrm libICE libSM libX11 libXau
		libXaw libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXft
		libXi libXinerama libXmu libXp libXpm libXrandr libXrender libXScrnSaver libXt
		libXtst libXv libXvMC libXxf86dga libXxf86dga libXxf86vm"
KEYWORDS="-* amd64"
IUSE="opengl"

DEPEND="opengl? ( app-admin/eselect-opengl )"
RDEPEND=">=app-emulation/emul-linux-x86-baselibs-20071114
	x11-libs/libX11"

src_unpack() {
	emul-linux-x86_src_unpack
	rm -f "${S}/usr/lib32/libGL.so"
}

pkg_postinst() {
	#update GL symlinks
	use opengl && eselect opengl set --use-old
}

