# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PortageXS/PortageXS-0.02.08.ebuild,v 1.2 2008/07/02 18:22:56 the_paya Exp $

EAPI="prefix"

inherit perl-module eutils
DESCRIPTION="Portage abstraction layer for perl"
HOMEPAGE="http://download.mpsna.de/opensource/PortageXS/"
SRC_URI="http://download.mpsna.de/opensource/PortageXS/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="minimal"
SRC_TEST="do"

DEPEND="dev-lang/perl
	dev-perl/Term-ANSIColor
	!minimal? ( dev-perl/IO-Socket-SSL
				perl-core/Sys-Syslog )"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-prefix.patch
	cd "${S}"
	eprefixify \
		lib/PortageXS/Core.pm \
		lib/PortageXS.pm \
		usr/bin/portagexs_client \
		usr/sbin/portagexsd

	if use minimal ; then
		rm -r ${S}/usr
		rm -r ${S}/etc/init.d
		rm -r ${S}/etc/pxs/certs
		rm ${S}/etc/pxs/portagexsd.conf
		rm -r ${S}/lib/PortageXS/examples
	fi
}

pkg_preinst() {
	if use !minimal ; then
		cp -r ${S}/usr ${ED}
	fi
	cp -r ${S}/etc ${ED}
}

pkg_postinst() {
	if [ -d /etc/portagexs ]; then
		elog "/etc/portagexs has been moved to /etc/pxs for convenience. It is safe"
		elog "to delete old /etc/portagexs directories."
	fi
}
