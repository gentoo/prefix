# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-baselibs/emul-linux-x86-baselibs-20071114.ebuild,v 1.2 2007/11/16 17:21:36 kingtaco Exp $

EAPI="prefix"

inherit emul-linux-x86

LICENSE="|| ( Artistic GPL-2 ) || ( BSD GPL-2 ) BZIP2 CRACKLIB DB
		GPL-2 || ( GPL-2 AFL-2.1 ) LGPL-2 LGPL-2.1 MIT OPENLDAP openssl
		PAM ZLIB as-is"
KEYWORDS="~amd64-linux"

DEPEND=""
RDEPEND="!<app-emulation/emul-linux-x86-medialibs-10.2" # bug 168507

src_unpack() {
	export ALLOWED="(${S}/lib32/security/pam_filter/upperLOWER|${S}/etc/env.d)"
	emul-linux-x86_src_unpack
	rm -rf "${S}/etc/env.d/binutils/" \
			"${S}/usr/lib32/binutils/" \
			"${S}/usr/lib32/engines/" \
			"${S}/usr/lib32/openldap/" \
			"${S}/usr/lib32/python2.4/"

	ln -s ../share/terminfo "${S}/usr/lib32/terminfo"
}
