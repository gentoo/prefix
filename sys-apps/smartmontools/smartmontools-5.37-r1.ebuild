# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/smartmontools/smartmontools-5.37-r1.ebuild,v 1.1 2008/03/10 19:29:06 robbat2 Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="control and monitor storage systems using the Self-Monitoring, Analysis and Reporting Technology System (S.M.A.R.T.)"
HOMEPAGE="http://smartmontools.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static minimal"

RDEPEND=""
DEPEND=""

src_compile() {
	use static && append-ldflags -static
	econf || die
	emake || die
}

src_install() {
	dosbin smartctl || die "dosbin smartctl"
	dodoc AUTHORS CHANGELOG NEWS README TODO WARNINGS
	doman smartctl.8
	if ! use minimal; then
	dosbin smartd || die "dosbin smartd"
		doman smartd*.[58]
		newdoc smartd.conf smartd.conf.example
		docinto examplescripts
		dodoc examplescripts/*
		rm -f "${ED}"/usr/share/doc/${PF}/examplescripts/Makefile*

		insinto /etc
		doins smartd.conf

		newinitd "${FILESDIR}"/smartd.rc smartd
		newconfd "${FILESDIR}"/smartd.confd smartd
	fi
}

pkg_postinst() {
	if ! use minimal; then
		elog "You need the 'mail' command if you configured smartd to send reports"
		elog "via email, 'emerge virtual/mailx' to get a mailer"
	fi
}
