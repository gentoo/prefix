# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/cpufrequtils/cpufrequtils-002-r4.ebuild,v 1.1 2008/08/11 17:46:53 armin76 Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="Userspace utilities for the Linux kernel cpufreq subsystem"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/cpufreq/cpufrequtils.html"
SRC_URI="mirror://kernel/linux/utils/kernel/cpufreq/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug nls"

DEPEND="sys-fs/sysfsutils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-parallel-make.patch
}

src_compile() {
	local debug=false nls=false

	use debug && debug=true
	use nls && nls=true

	emake V=true DEBUG=${debug} NLS=${nls} \
		CC=$(tc-getCC) LD=$(tc-getCC) AR=$(tc-getAR) STRIP=echo RANLIB=$(tc-getRANLIB) \
		LIBTOOL="${EPREFIX}"/usr/bin/libtool INSTALL="${EPREFIX}"/usr/bin/install \
		|| die "emake failed"
}

src_install() {
	local nls=false

	use nls && nls=true

	make DESTDIR="${D}" NLS=${nls} mandir="${EPREFIX}"/usr/share/man libdir="${EPREFIX}"/usr/$(get_libdir) \
		INSTALL="${EPREFIX}"/usr/bin/install \
		bindir="${EPREFIX}"/usr/bin \
		includedir="${EPREFIX}"/usr/include \
		localedir="${EPREFIX}"/usr/share/locale \
		install || die "make install failed"

	newconfd "${FILESDIR}"/${PN}-conf.d ${PN}
	newinitd "${FILESDIR}"/${PN}-init.d ${PN}

	dodoc AUTHORS README
}
