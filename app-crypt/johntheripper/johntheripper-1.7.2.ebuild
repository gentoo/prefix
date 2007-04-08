# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/johntheripper/johntheripper-1.7.2.ebuild,v 1.13 2007/04/04 17:57:37 phreak Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs pax-utils

MY_PBASE=${P/theripper/}
MY_PNBASE=${PN/theripper/}
S=${WORKDIR}/${MY_PBASE}
DESCRIPTION="fast password cracker"
HOMEPAGE="http://www.openwall.com/john/"
SRC_URI="http://www.openwall.com/john/f/${MY_PBASE}.tar.gz
		http://www.openwall.com/john/contrib/${MY_PNBASE}-1.7-all-4.diff.gz"

# banquise-to-bigpatch-17.patch.bz2"
# based off /var/tmp/portage/johntheripper-1.6.40

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="mmx altivec"

RDEPEND="virtual/libc
	>=dev-libs/openssl-0.9.7"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${DISTDIR}"/${MY_PNBASE}-1.7-all-4.diff.gz
	epatch "${FILESDIR}"/${P}-*.patch

	ebegin "Applying ${P}-Makefile.patch"
	sed -i -e "s|^CFLAGS.*|CFLAGS= -c -Wall ${CFLAGS}|" \
		-e 's|^LDFLAGS.*|LDFLAGS= -lm|' "${S}"/src/Makefile
	eend $?

	ebegin "Applying ${P}-john.conf.patch"
	sed -i -e 's:$JOHN:'"${EPREFIX}"'/usr/share/john:g' "${S}"/run/john.conf
	eend $?

	# The stuff below in the makefile attempts to do this, but that doesn't
	# work, so we do it here right.  To avoid diffs, we leave the stuff below
	# in.
	ebegin "Sedding src/params.h"
	sed -i \
		-e '/CFG_FULL_NAME/s|".*"|"'"${EPREFIX}"'/etc/john/john.conf"|' \
		-e '/CFG_ALT_NAME/s|".*"|"'"${EPREFIX}"'/etc/john/john.ini"|' \
		"${S}"/src/params.h
	eend $?
}


src_compile() {
	cd "${S}"/src
	# Note this program uses AS and LD incorrectly
	OPTIONS="CPP=$(tc-getCXX) CC=$(tc-getCC) AS=$(tc-getCC) LD=$(tc-getCC) \
		OPT_NORMAL= OPT_INLINE= JOHN_SYSTEMWIDE=1
		CFG_FULL_NAME=/etc/john/john.conf
		CFG_ALT_NAME=/etc/john/john.ini"

	if use x86 ; then
		if use mmx ; then
			emake ${OPTIONS} linux-x86-mmx || die "Make failed"
		else
			emake ${OPTIONS} linux-x86-any || die "Make failed"
		fi
	elif use amd64 ; then
		emake ${OPTIONS} generic || die "Make failed"
	elif use alpha ; then
		emake ${OPTIONS} linux-alpha || die "Make failed"
	elif use sparc; then
		emake ${OPTIONS} linux-sparc  || die "Make failed"
	elif use amd64; then
		emake ${OPTIONS} linux-x86-64  || die "Make failed"
	elif use ppc-macos; then
		if use altivec; then
			emake ${OPTIONS} macosx-ppc32-altivec || die "Make failed"
		else
			emake ${OPTIONS} macosx-ppc32 || die "Make failed"
		fi
		# for Tiger this can be macosx-ppc64
	elif use ppc64; then
		if use altivec; then
			emake ${OPTIONS} linux-ppc32-altivec  || die "Make failed"
		else
			emake ${OPTIONS} linux-ppc64  || die "Make failed"
		fi
		# linux-ppc64-altivec is slightly slower than linux-ppc32-altivec for most hash types.
		# as per the Makefile comments
	elif use ppc; then
		if use altivec; then
			emake ${OPTIONS} linux-ppc32-altivec  || die "Make failed"
		else
			emake ${OPTIONS} linux-ppc32 || die "Make failed"
		fi
	else
		emake ${OPTIONS} generic || die "Make failed"
	fi

	# currently broken
	#emake bench || die "make failed"
}


src_test() {
	cd run
	if  [[ -f ${EROOT}/etc/john/john.conf || -f ${EROOT}/etc/john/john.ini  ]]
	then
		./john --test || die 'self test failed'
	else
		ewarn "selftest requires /etc/john/john.conf or /etc/john/john.ini"
	fi
}

src_install() {
	# config files
	insinto /etc/john
	doins run/john.conf

	# executables
	dosbin run/john
	newsbin run/mailer john-mailer

	pax-mark -m "${ED}"/usr/sbin/john

	dosym john /usr/sbin/unafs
	dosym john /usr/sbin/unique
	dosym john /usr/sbin/unshadow

	# for EGG only
	dosym john /usr/sbin/undrop

	#newsbin src/bench john-bench

	# share
	insinto /usr/share/john/
	doins run/*.chr run/password.lst

	# documentation
	dodoc doc/*
}
