# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/johntheripper/johntheripper-1.7.2-r4.ebuild,v 1.1 2008/01/11 07:10:26 alonbl Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs pax-utils

MY_PN="${PN/theripper/}"
MY_P="${MY_PN/theripper/}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="fast password cracker"
HOMEPAGE="http://www.openwall.com/john/"

SRC_URI="http://www.openwall.com/john/f/${MY_P}.tar.gz
	http://www.openwall.com/john/contrib/${MY_P}-all-9.diff.gz"
# When mpi stable:
#	mpi? ( http://bindshell.net/tools/johntheripper/${MY_P}-bp17-mpi2.patch.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="mmx altivec sse2 custom-cflags"

RDEPEND=">=dev-libs/openssl-0.9.7"
# When mpi stable:
#	mpi? ( sys-cluster/openmpi )"
DEPEND="${RDEPEND}"

get_target() {
	if use x86 ; then
		if use sse2 ; then
			echo "linux-x86-sse2"
		elif use mmx ; then
			echo "linux-x86-mmx"
		else
			echo "linux-x86-any"
		fi
	elif use alpha ; then
		echo "linux-alpha"
	elif use sparc; then
		echo "linux-sparc"
	elif use amd64; then
		echo "linux-x86-64"
	elif use ppc-macos; then
		if use altivec; then
			echo "macosx-ppc32-altivec"
		else
			echo "macosx-ppc32"
		fi
		# for Tiger this can be macosx-ppc64
	elif use x86-macos; then
		if use sse2; then
			echo "macosx-x86-sse"
		else
			echo "macosx-x86"
		fi
	elif use x86-solaris; then
		echo "solaris-x86-any"
	elif use ppc64; then
		if use altivec; then
			echo "linux-ppc32-altivec"
		else
			echo "linux-ppc64"
		fi
		# linux-ppc64-altivec is slightly slower than linux-ppc32-altivec for most hash types.
		# as per the Makefile comments
	elif use ppc; then
		if use altivec; then
			echo "linux-ppc32-altivec"
		else
			echo "linux-ppc32"
		fi
	else
		echo "generic"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

# When mpi stable:
#	if use mpi ; then
#		epatch "${WORKDIR}"/${MY_P}-bp17-mpi2.patch
#	else

	cd "${S}/src"
	epatch "${WORKDIR}"/${MY_P}-all-9.diff

	for p in stackdef.S stackdef-2.S mkdir-sandbox; do
		epatch "${FILESDIR}/${P}-${p}.patch"
	done
}

src_compile() {
	cd "${S}/src"

	use custom-cflags || strip-flags
	append-flags -fno-PIC -fno-PIE
	append-ldflags -nopie

	emake \
		CPP=$(tc-getCXX) CC=$(tc-getCC) AS=$(tc-getCC) LD=$(tc-getCC) \
		CFLAGS="-c -Wall ${CFLAGS} -DJOHN_SYSTEMWIDE \
			-DJOHN_SYSTEMWIDE_HOME=\"\\\"${EPREFIX}/etc/john\\\"\"" \
		LDFLAGS="${LDFLAGS}" \
		OPT_NORMAL="" \
		$(get_target) \
		|| die "make failed"
}

src_test() {
	cd "${S}/run"
	if  [ -f ${EROOT}/etc/john/john.conf -o -f ${EROOT}/etc/john/john.ini ]; then
# When mpi stable:
#		if use mpi ; then
#			mpirun -np 2 ./john --test || die 'self test failed'
#		else

		./john --test || die 'self test failed'
	else
		ewarn "selftest requires ${EROOT}/etc/john/john.conf or ${EROOT}/etc/john/john.ini"
	fi
}

src_install() {
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

	# config files
	insinto /etc/john
	doins run/john.conf
	doins run/*.chr run/password.lst

	# documentation
	dodoc doc/*
}
