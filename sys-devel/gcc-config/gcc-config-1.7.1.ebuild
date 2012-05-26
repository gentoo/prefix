# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/gcc-config-1.7.1.ebuild,v 1.1 2012/05/13 20:14:06 vapier Exp $

inherit unpacker toolchain-funcs multilib prefix

DESCRIPTION="utility to manage compilers"
HOMEPAGE="http://git.overlays.gentoo.org/gitweb/?p=proj/gcc-config.git"
SRC_URI="mirror://gentoo/${P}.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""


src_unpack() {
	die "FIXME!"
	cp "${FILESDIR}"/wrapper-${W_VER}.c "${S}"/wrapper.c || die
	cp "${FILESDIR}"/${PN}-${PV}  "${S}/"${PN}-${PV} || die
	eprefixify "${S}"/wrapper.c "${S}"/${PN}-${PV}
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	emake \
		DESTDIR="${D}" \
		PV="${PV}" \
		SUBLIBDIR="$(get_libdir)" \
		install || die
}

pkg_postinst() {
	# Scrub eselect-compiler remains
	rm -f "${EROOT}"/etc/env.d/05compiler &

	# Make sure old versions dont exist #79062
	rm -f "${EROOT}"/usr/sbin/gcc-config &

	# We not longer use the /usr/include/g++-v3 hacks, as
	# it is not needed ...
	rm -f "${EROOT}"/usr/include/g++{,-v3} &

	# Do we have a valid multi ver setup ?
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done

	wait
}
