# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-compat/emul-linux-x86-compat-1.0-r1.ebuild,v 1.5 2006/03/09 01:51:23 flameeyes Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="emul-linux-x86 version of lib-compat, with the addition of a 32bit libgcc_s and the libstdc++ versions provided by gcc 3.3 and 3.4 for non-multilib systems."
SRC_URI="mirror://gentoo/emul-linux-x86-compat-${PV}.tar.bz2"
HOMEPAGE="http://www.gentoo.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="-* amd64"
IUSE=""

# stop confusing portage 0.o
S=${WORKDIR}

DEPEND="virtual/libc"

RESTRICT="nostrip"

src_unpack() {
	unpack ${A}
	# Remove libsmpeg to avoid collision with emul-sdl
	rm -f ${S}/emul/linux/x86/usr/lib/libsmpeg*
}

src_install() {
	dodir /	
	# everything should already be in the right place :)
	cp -Rpvf ${WORKDIR}/* ${ED}/

	cp "${FILESDIR}"/75emul-linux-x86-compat "${T}"/75emul-linux-x86-compat
	eprefixify "${T}"/75emul-linux-x86-compat

	doenvd "${T}"/75emul-linux-x86-compat
}
