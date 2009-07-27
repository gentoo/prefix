# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/valgrind/valgrind-3.4.1-r1.ebuild,v 1.1 2009/07/26 12:05:52 griffon26 Exp $

inherit autotools eutils flag-o-matic toolchain-funcs

DESCRIPTION="An open-source memory debugger for GNU/Linux"
HOMEPAGE="http://www.valgrind.org"
SRC_URI="http://www.valgrind.org/downloads/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="mpi"

DEPEND="mpi? ( virtual/mpi )"
RDEPEND="${DEPEND}
	!dev-util/callgrind"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# make sure our CFLAGS are respected
	einfo "Changing configure.in to respect CFLAGS"
	sed -i -e 's:^CFLAGS="-Wno-long-long":CFLAGS="$CFLAGS -Wno-long-long":' configure.in

	# undefined references to __guard and __stack_smash_handler in VEX (bug #114347)
	einfo "Changing Makefile.flags.am to disable SSP"
	sed -i -e 's:^AM_CFLAGS_BASE = :AM_CFLAGS_BASE = -fno-stack-protector :' Makefile.flags.am

	# Correct hard coded doc location
	sed -i -e "s:doc/valgrind:doc/${P}:" docs/Makefile.am

	# Remove defaulting to ppc32-linux on ppc64 without multilib
	# "valgrind: failed to start tool 'memcheck' for platform 'ppc32-linux':
	#  No such file or directory"
	if use ppc64 && ! has_multilib_profile; then
		epatch "${FILESDIR}/valgrind-3.3.0-only64bit.patch"
	fi

	# Use local labels in inline asm to prevent 'symbol already defined' errors
	# when optimisation is on (bug #234644).
	epatch "${FILESDIR}/valgrind-3.3.1-local-labels.patch"

	# valgrind spits out many false positives on amd64 because of glibc-2.10's
	# optimized strlen if there is no debug info for glibc (bug #274771). This
	# patch adds a run-time error if debug info cannot be found.
	epatch "${FILESDIR}/valgrind-3.4.1-x86_64-ldso-strlen.patch"

	# Fix up some suppressions that were not general enough for glibc versions
	# with more than just a major and minor number.
	epatch "${FILESDIR}/valgrind-3.4.1-glibc-2.10.1.patch"

	# Regenerate autotools files
	eautoreconf
}

src_compile() {
	local myconf

	# -fomit-frame-pointer	"Assembler messages: Error: junk `8' after expression"
	#                       while compiling insn_sse.c in none/tests/x86
	# -fpie                 valgrind seemingly hangs when built with pie on
	#                       amd64 (bug #102157)
	# -fstack-protector     more undefined references to __guard and __stack_smash_handler
	#                       because valgrind doesn't link to glibc (bug #114347)
	# -ggdb3                segmentation fault on startup
	filter-flags -fomit-frame-pointer
	filter-flags -fpie
	filter-flags -fstack-protector
	replace-flags -ggdb3 -ggdb2

	# gcc 3.3.x fails to compile valgrind with -O3 (bug #129776)
	if [ "$(gcc-version)" == "3.3" ] && is-flagq -O3; then
		ewarn "GCC 3.3 cannot compile valgrind with -O3 in CFLAGS, using -O2 instead."
		replace-flags -O3 -O2
	fi

	if use amd64 || use ppc64; then
		! has_multilib_profile && myconf="${myconf} --enable-only64bit"
	fi

	# Don't use mpicc unless the user asked for it (bug #258832)
	if ! use mpi; then
		myconf="${myconf} --without-mpicc"
	fi

	econf ${myconf} || die "Configure failed!"
	emake || die "Make failed!"
}

src_install() {
	make DESTDIR="${D}" install || die "Install failed!"
	dodoc ACKNOWLEDGEMENTS AUTHORS FAQ.txt NEWS README*
}

pkg_postinst() {
	if use ppc || use ppc64 || use amd64 ; then
		ewarn "Valgrind will not work on ppc, ppc64 or amd64 if glibc does not have"
		ewarn "debug symbols (see https://bugs.gentoo.org/show_bug.cgi?id=214065"
		ewarn "and http://bugs.gentoo.org/show_bug.cgi?id=274771)."
		ewarn "To fix this you can add splitdebug to FEATURES in make.conf and"
		ewarn "remerge glibc."
	fi
}
