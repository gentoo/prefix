# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-mta/esmtp/esmtp-0.5.0-r2.ebuild,v 1.2 2005/05/12 17:28:32 ferdy Exp $

EAPI="prefix"

inherit mailer

DESCRIPTION="esmtp is a user configurable relay-only Mail Transfer Agent (MTA) with a sendmail compatible syntax"
HOMEPAGE="http://esmtp.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""
DEPEND="virtual/libc
	net-libs/libesmtp
	dev-libs/openssl"

src_install() {
	make DESTDIR=${D} install || die "einstall failed"
	dodoc AUTHORS COPYING ChangeLog NEWS README TODO

	if use mailwrapper ; then
		mv ${ED}/usr/sbin/sendmail ${ED}/usr/bin/sendmail.esmtp
		mv ${ED}/usr/bin/mailq ${ED}/usr/bin/mailq.esmtp
		mv ${ED}/usr/bin/newaliases ${ED}/usr/bin/newaliases.esmtp
		mailer_install_conf
	fi
}
