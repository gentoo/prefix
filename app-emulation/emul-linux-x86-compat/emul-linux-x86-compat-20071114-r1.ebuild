# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-compat/emul-linux-x86-compat-20071114-r1.ebuild,v 1.2 2007/11/24 01:16:48 kingtaco Exp $

EAPI="prefix"

inherit emul-linux-x86

DESCRIPTION="emul-linux-x86 version of lib-compat, with the addition of a 32bit libgcc_s and the libstdc++ versions provided by gcc 3.3 and 3.4 for non-multilib systems."
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
IUSE=""

S=${WORKDIR}

QA_TEXTRELS_amd64="usr/lib32/libg++.so.2.7.2.8
	usr/lib32/libstdc++.so.2.7.2.8"

src_install() {
	emul-linux-x86_src_install
	dosym libstdc++-v3/libstdc++.so.5 /usr/lib32/libstdc++.so.5
}
