# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/cpufrequtils/cpufrequtils-007.ebuild,v 1.1 2010/01/16 23:57:40 vapier Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="Userspace utilities for the Linux kernel cpufreq subsystem"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/cpufreq/cpufrequtils.html"
SRC_URI="mirror://kernel/linux/utils/kernel/cpufreq/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug nls"

DEPEND="sys-fs/sysfsutils"

ft() { use $1 && echo true || echo false ; }

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-007-build.patch
	epatch "${FILESDIR}"/${PN}-007-nls.patch #205576 #292246
	export DEBUG=$(ft debug) V=true NLS=$(ft nls)
	unset bindir sbindir includedir localedir confdir
	export mandir="${EPREFIX}/usr/share/man"
	export libdir="${EPREFIX}/usr/$(get_libdir)"
	export docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		STRIP=: \
		RANLIB="$(tc-getRANLIB)" \
		LIBTOOL="${EPREFIX}"/usr/bin/libtool \
		INSTALL="${EPREFIX}"/usr/bin/install \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS README

	newinitd "${FILESDIR}"/${PN}-init.d-006 ${PN} || die
	newconfd "${FILESDIR}"/${PN}-conf.d-006 ${PN}
}
