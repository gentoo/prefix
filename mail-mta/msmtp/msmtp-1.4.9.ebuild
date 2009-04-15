# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-mta/msmtp/msmtp-1.4.9.ebuild,v 1.3 2008/03/22 14:51:06 tove Exp $

DESCRIPTION="An SMTP client and SMTP plugin for mail user agents such as Mutt"
HOMEPAGE="http://msmtp.sourceforge.net/"
SRC_URI="mirror://sourceforge/msmtp/${P}.tar.bz2"
LICENSE="GPL-2"
IUSE="ssl gnutls sasl mailwrapper doc nls"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
DEPEND="virtual/libc
	dev-util/pkgconfig
	ssl? (
		gnutls? ( >=net-libs/gnutls-1.2.0 )
		!gnutls?  ( >=dev-libs/openssl-0.9.6 )
	)
	sasl? ( >=virtual/gsasl-0.2.4 )
	nls? ( sys-devel/gettext )"
RDEPEND="mailwrapper? ( >=net-mail/mailwrapper-0.2 )
	!mailwrapper? ( !virtual/mta )"
PROVIDE="virtual/mta"

src_compile () {
	local myconf

	if use ssl && use gnutls ; then
		myconf="${myconf} --enable-ssl --with-ssl=gnutls"
	elif use ssl && ! use gnutls ; then
		myconf="${myconf} --enable-ssl --with-ssl=openssl"
	else
		myconf="${myconf} --disable-ssl"
	fi

	econf \
		$(use_enable sasl gsasl) \
		$(use_enable nls) \
		${myconf} \
	|| die "configure failed"

	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "install failed"

	if use mailwrapper; then
		insinto /etc/mail
		doins "${FILESDIR}"/mailer.conf
	else
		dodir /usr/sbin /usr/lib
		dosym /usr/bin/msmtp /usr/sbin/sendmail || die "dosym failed"
	fi

	dodoc AUTHORS ChangeLog NEWS README* THANKS \
		doc/{Mutt+msmtp.txt,msmtprc*} || die "dodoc failed"

	if use doc ; then
		dohtml doc/msmtp.html || die "dohtml failed"
		dodoc doc/msmtp.pdf
	fi
}
