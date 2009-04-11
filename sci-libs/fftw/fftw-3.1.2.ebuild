# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/fftw/fftw-3.1.2.ebuild,v 1.13 2008/06/23 14:31:13 bicatali Exp $

inherit flag-o-matic eutils toolchain-funcs autotools fortran

DESCRIPTION="Fast C library for the Discrete Fourier Transform"
HOMEPAGE="http://www.fftw.org/"
SRC_URI="http://www.fftw.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="3.0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="altivec fortran sse sse2 test"

DEPEND="test? ( dev-lang/perl )"

pkg_setup() {
	FORTRAN="gfortran ifc g77"
	use fortran && fortran_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-configure.ac.patch
	# fix info file
	sed -e 's/Texinfo documentation system/Libraries/' \
		-i doc/fftw3.info || die "failed to fix info file"
	AT_M4DIR=m4 eautoreconf
	cd "${WORKDIR}"
	mv ${P} ${P}-single
	cp -pPR ${P}-single ${P}-double
	cp -pPR ${P}-single ${P}-longdouble
}

src_compile() {
	# filter -Os according to docs
	replace-flags -Os -O2

	local myconfcommon="--enable-shared --enable-threads $(use_enable fortran)"
	local myconfsingle=""
	local myconfdouble=""
	local myconflongdouble=""

	if use sse2; then
		myconfsingle="$myconfsingle --enable-sse"
		myconfdouble="$myconfdouble --enable-sse2"
	elif use sse; then
		myconfsingle="$myconfsingle --enable-sse"
	fi
	# altivec only helps floats, not doubles
	if use altivec; then
		myconfsingle="$myconfsingle --enable-altivec"
	fi

	cd "${S}-single"
	econf \
		${myconfcommon} \
		--enable-float \
		${myconfsingle} || \
			die "./configure in single failed"
	emake || die "emake single failed"

	#the only difference here is no --enable-float
	cd "${S}-double"
	econf \
		${myconfcommon} \
		${myconfdouble} || \
		die "./configure in double failed"
	emake || die "emake double failed"

	#the only difference here is --enable-long-double
	cd "${S}-longdouble"
	econf \
		${myconfcommon} \
		--enable-long-double \
		${myconflongdouble} || \
		die "./configure in long double failed"
	emake || die "emake long double failed"
}

src_install () {
	# all builds are installed in the same place
	# libs have distinuguished names; include files, docs etc. identical.
	for i in single double longdouble; do
		cd "${S}-${i}"
		emake DESTDIR="${D}" install || die "emake install for ${i} failed"
	done

	# Install documentation.
	cd "${S}-single"
	dodoc AUTHORS ChangeLog NEWS README TODO COPYRIGHT CONVENTIONS || die
	cd doc/html
	dohtml -r .
}

src_test () {
	# We want this to be a reasonably quick test, but that is still hard...
	ewarn "This test series will take 30 minutes on a modern 2.5Ghz machine"
	# Do not increase the number of threads, it will not help your performance
	local testbase="perl check.pl --nthreads=1 --estimate"
	for d in single double longdouble; do
		cd "${S}-${d}"/tests
		for p in 0 1 2; do
			n="${d/longdouble/long double} / ${p}-D"
			einfo "Testing $n"
			${testbase} -${p}d || die "Failure: $n"
		done
	done
}
