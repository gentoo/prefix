# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-filter/procmail/procmail-3.22-r8.ebuild,v 1.2 2006/10/08 00:38:39 vapier Exp $

inherit eutils flag-o-matic prefix

DESCRIPTION="Mail delivery agent/filter"
HOMEPAGE="http://www.procmail.org/"
SRC_URI="http://www.procmail.org/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="mbox selinux"

DEPEND="virtual/libc virtual/mta"
RDEPEND="virtual/libc
	selinux? ( sec-policy/selinux-procmail )"
PROVIDE="virtual/mda"

src_compile() {
	# -finline-functions (implied by -O3) leaves strstr() in an infinite loop.
	# To work around this, we append -fno-inline-functions to CFLAGS
	append-flags -fno-inline-functions

	sed -e "s:CFLAGS0 = -O:CFLAGS0 = ${CFLAGS}:" \
		-e "s:LOCKINGTEST=__defaults__:#LOCKINGTEST=__defaults__:" \
		-e "s:#LOCKINGTEST=/tmp:LOCKINGTEST=${EPREFIX}/tmp:" \
		-i Makefile

	if ! use mbox ; then
		echo "# Use maildir-style mailbox in user's home directory" > ${S}/procmailrc
		echo 'DEFAULT=$HOME/.maildir/' >> ${S}/procmailrc
		cd ${S}
		epatch ${FILESDIR}/gentoo-maildir2.diff
	else
		echo '# Use mbox-style mailbox in /var/spool/mail' > ${S}/procmailrc
		echo "DEFAULT=${EPREFIX}/var/spool/mail/\$LOGNAME" >> ${S}/procmailrc
	fi

	# Do not use lazy bindings on lockfile and procmail
	if [[ ${CHOST} != *-darwin* ]]; then
		epatch "${FILESDIR}/${PN}-lazy-bindings.diff"
	fi

	# Fix for bug #102340
	epatch "${FILESDIR}/${PN}-comsat-segfault.diff"

	# Fix for bug #119890
	epatch "${FILESDIR}/${PN}-maxprocs-fix.diff"

	# Prefixify config.h
	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify config.h Makefile src/autoconf src/recommend.c

	emake || die
}

src_install() {
	cd "${S}"/new
	insinto /usr/bin
	insopts -m 6755
	doins procmail || die

	insopts -m 2755
	doins lockfile || die

	dobin formail mailstat || die
	insopts -m 0644

	doman *.1 *.5

	cd "${S}"
	dodoc Artistic FAQ FEATURES HISTORY INSTALL KNOWN_BUGS README

	insinto /etc
	doins procmailrc || die

	docinto examples
	dodoc examples/*
}
