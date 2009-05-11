# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-compat/emul-linux-x86-compat-20071125-r1.ebuild,v 1.3 2009/05/10 18:32:57 arfrever Exp $

inherit emul-linux-x86 eutils

DESCRIPTION="emul-linux-x86 version of lib-compat, with the addition of a 32bit libgcc_s and the libstdc++ versions provided by gcc 3.3 and 3.4 for non-multilib systems."
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux"
RESTRICT="strip"
IUSE=""

S=${WORKDIR}

QA_TEXTRELS_amd64="usr/lib32/libg++.so.2.7.2.8
	usr/lib32/libstdc++.so.2.7.2.8"
QA_DT_HASH="usr/lib32/.*"

src_install() {
	emul-linux-x86_src_install
#	dosym libstdc++-v3/libstdc++.so.5 /usr/lib32/libstdc++.so.5
	doenvd "${FILESDIR}/99libstdc++32"
}
