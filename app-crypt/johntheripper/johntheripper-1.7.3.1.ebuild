# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/johntheripper/johntheripper-1.7.3.1.ebuild,v 1.7 2009/04/14 10:22:40 armin76 Exp $

inherit eutils flag-o-matic toolchain-funcs pax-utils

JUMBO='all-3'
MPI='mpi8-small'

MY_PN="${PN/theripper/}"
MY_P="${MY_PN/theripper/}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="fast password cracker"
HOMEPAGE="http://www.openwall.com/john/"

SRC_URI="http://www.openwall.com/john/g/${MY_P}.tar.gz
	!minimal? ( ftp://ftp.openwall.com/john/contrib/historical/${MY_P}-${JUMBO}.diff.gz )
	mpi? ( http://bindshell.net/tools/johntheripper/${MY_P}-${MPI}.patch.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
EAPI=1
IUSE="mmx altivec sse2 custom-cflags -minimal -mpi"

# Seems a bit fussy with other MPI implementations.
RDEPEND="!minimal? ( >=dev-libs/openssl-0.9.7 )
	mpi? ( sys-cluster/openmpi )"
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

#pkg_setup() {
#	if use mpi && built_with_use sys-cluster/mpich2 threads; then
#		die 'cannot work with sys-cluster/mpich2 USE=threads'
#		#http://bindshell.net/tools/johntheripper/
#	fi
#}

src_unpack() {
	unpack ${A}
	cd "${S}"
	PATCHLIST=""
	if use mpi ; then
		epatch "${WORKDIR}"/${MY_P}-${MPI}.patch
		# avoid the conflict on JOHN_VERSION until a better compromise is made
		sed -i 's/_mpi"/"/' src/params.h
	fi
	if ! use minimal ; then
		epatch "${WORKDIR}"/${MY_P}-${JUMBO}.diff
		PATCHLIST=stackdef.S
	fi
	PATCHLIST="${PATCHLIST} params.h mkdir-sandbox prefix cflags"

	cd "${S}/src"
	for p in ${PATCHLIST}; do
		epatch "${FILESDIR}/${P}-${p}.patch"
	done

	sed -e "s/LDFLAGS  *=  */override LDFLAGS += /" -e "/LDFLAGS/s/-s//" -e '/LDFLAGS/s/-L[^ ]* //g' -i Makefile || die "sed Makefile failed"
}

src_compile() {
	cd "${S}/src"

	use custom-cflags || strip-flags
	append-flags -fno-PIC -fno-PIE
	append-ldflags -nopie

	CPP=$(tc-getCXX) CC=$(tc-getCC) AS=$(tc-getCC) LD=$(tc-getCC)
	use mpi && CPP=mpicxx CC=mpicc AS=mpicc LD=mpicc
	emake \
		CPP=${CPP} CC=${CC} AS=${AS} LD=${LD} \
		CFLAGS="-c -Wall ${CFLAGS} -DJOHN_SYSTEMWIDE=1 -DJOHN_SYSTEMWIDE_HOME=\\\"\\\\\\\"${EPREFIX}/etc/john\\\\\\\"\\\" -DJOHN_SYSTEMWIDE_EXEC=\\\"\\\\\\\"${EPREFIX}/usr/libexec/john\\\\\\\"\\\" -DCFG_FULL_NAME=\\\"\\\\\\\"${EPREFIX}/etc/john/john.conf\\\\\\\"\\\" -DCFG_ALT_NAME=\\\"\\\\\\\"${EPREFIX}/etc/john/john.ini\\\\\\\"\\\"" \
		LDFLAGS="${LDFLAGS}" \
		OPT_NORMAL="" \
		$(get_target) \
		|| die "emake failed"
}

src_test() {
	cd "${S}/run"
	if  [ -f ${EROOT}/etc/john/john.conf -o -f ${EROOT}/etc/john/john.ini ]; then
		# This requires that MPI is actually 100% online on your system, which might not
		# be the case, depending on which MPI implementation you are using.
		#if use mpi ; then
		#	mpirun -np 2 ./john --test || die 'self test failed'
		#else

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

	# jumbo-patch additions
	if ! use minimal ; then
		dosym john /usr/sbin/undrop
		# >=all-4
		#dosbin run/calc_stat
		#dosbin run/genmkvpwd
		#dosbin run/mkvcalcproba
		insinto /etc/john
		# >=all-4
		#doins run/genincstats.rb run/stats
		doins run/netscreen.py run/sap_prepare.pl
	fi

	#newsbin src/bench john-bench

	# config files
	insinto /etc/john
	doins run/john.conf
	doins run/*.chr run/password.lst

	# documentation
	dodoc doc/*
}
