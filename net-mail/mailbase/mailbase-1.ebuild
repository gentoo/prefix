# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/mailbase/mailbase-1.ebuild,v 1.21 2012/04/26 14:21:12 aballier Exp $

inherit pam eutils prefix

DESCRIPTION="MTA layout package"
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="pam"

RDEPEND="pam? ( virtual/pam )"

S=${WORKDIR}

pkg_setup() {
	enewgroup mail 12
	enewuser mail 8 -1 /var/spool/mail mail
	enewuser postmaster 14 -1 /var/spool/mail
}

src_install() {
	dodir /etc/mail
	insinto /etc/mail
	doins "${FILESDIR}"/aliases
	cp "${FILESDIR}"/mailcap .
	epatch "${FILESDIR}"/mailcap-prefix.patch
	eprefixify mailcap
	insinto /etc/
	doins mailcap

	keepdir /var/spool/mail
	fowners root:mail /var/spool/mail
	fperms 0775 /var/spool/mail
	dosym /var/spool/mail /var/mail

	newpamd "${FILESDIR}"/common-pamd-include pop
	newpamd "${FILESDIR}"/common-pamd-include imap
	if use pam ; then
		local p
		for p in pop3 pop3s pops ; do
			dosym pop /etc/pam.d/${p} || die
		done
		for p in imap4 imap4s imaps ; do
			dosym imap /etc/pam.d/${p} || die
		done
	fi
}

get_permissions_oct() {
	if [[ ${USERLAND} = GNU ]] ; then
		stat -c%a "${EROOT}$1"
	elif [[ ${USERLAND} = BSD ]] ; then
		stat -f%p "${EROOT}$1" | cut -c 3-
	fi
}

pkg_postinst() {
	if [[ "$(get_permissions_oct /var/spool/mail)" != "775" ]] ; then
		echo
		ewarn "Your ${EROOT}/var/spool/mail/ directory permissions differ from"
		ewarn "  those which mailbase set when you first installed it (0775)."
		ewarn "  If you did not change them on purpose, consider running:"
		ewarn
		ewarn "    chmod 0775 ${EROOT}/var/spool/mail/"
		echo
	fi
}
