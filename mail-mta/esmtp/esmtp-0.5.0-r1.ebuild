# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-mta/esmtp/esmtp-0.5.0-r1.ebuild,v 1.11 2007/04/24 18:33:37 dertobi123 Exp $

DESCRIPTION="esmtp is a user configurable relay-only Mail Transfer Agent (MTA) with a sendmail compatible syntax"
HOMEPAGE="http://esmtp.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="mailwrapper"
DEPEND="virtual/libc
	net-libs/libesmtp
	dev-libs/openssl"
RDEPEND="${DEPEND}
	mailwrapper? ( >=net-mail/mailwrapper-0.2 )
	!mailwrapper? ( !virtual/mta )"
PROVIDE="virtual/mta"

src_install() {
	make DESTDIR=${D} install || die "einstall failed"
	dodoc AUTHORS COPYING ChangeLog NEWS README TODO

	if use mailwrapper
	then
		# We install sendmail binary to be compatible with mailwrapper
		mv ${ED}/usr/sbin/sendmail ${ED}/usr/sbin/sendmail.esmtp
		dosym /usr/sbin/sendmail /usr/lib/sendmail
		rm ${ED}/usr/bin/mailq ${ED}/usr/bin/newaliases
	fi
}
