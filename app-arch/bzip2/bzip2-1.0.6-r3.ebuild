# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bzip2/bzip2-1.0.6-r3.ebuild,v 1.11 2012/05/17 04:36:15 vapier Exp $

# XXX: atm, libbz2.a is always PIC :(, so it is always built quickly
#      (since we're building shared libs) ...

EAPI="2"

inherit eutils multilib toolchain-funcs flag-o-matic prefix

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SRC_URI="http://www.bzip.org/${PV}/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static static-libs"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.0.4-makefile-CFLAGS.patch
	epatch "${FILESDIR}"/${PN}-1.0.6-saneso.patch
	epatch "${FILESDIR}"/${PN}-1.0.4-man-links.patch #172986
	epatch "${FILESDIR}"/${PN}-1.0.6-progress.patch
	epatch "${FILESDIR}"/${PN}-1.0.3-no-test.patch
	epatch "${FILESDIR}"/${PN}-1.0.4-POSIX-shell.patch #193365
	epatch "${FILESDIR}"/${PN}-1.0.6-mingw.patch #393573

	epatch "${FILESDIR}"/${PN}-1.0.5-checkenv.patch # for AIX, Darwin?
	epatch "${FILESDIR}"/${PN}-1.0.4-prefix.patch
	eprefixify bz{diff,grep,more}
	# this a makefile for Darwin, which already "includes" saneso
	cp "${FILESDIR}"/${P}-Makefile-libbz2_dylib Makefile-libbz2_dylib || die

	# - Use right man path
	# - Generate symlinks instead of hardlinks
	# - pass custom variables to control libdir
	sed -i \
		-e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' \
		-e 's:ln -s -f $(PREFIX)/bin/:ln -s :' \
		-e 's:$(PREFIX)/lib:$(PREFIX)/$(LIBDIR):g' \
		Makefile || die

	if [[ ${CHOST} == *-hpux* ]] ; then
		sed -i -e 's,-soname,+h,' Makefile-libbz2_so || die "cannot replace -soname with +h"
		if [[ ${CHOST} == hppa*-hpux* && ${CHOST} != hppa64*-hpux* ]] ; then
			sed -i -e '/^SOEXT/s,so,sl,' Makefile-libbz2_so || die "cannot replace so with sl"
			sed -i -e '/^SONAME/s,=,=${EPREFIX}/lib/,' Makefile-libbz2_so || die "cannt set soname"
		fi
	elif [[ ${CHOST} == *-interix* ]] ; then
		sed -i -e 's,-soname,-h,' Makefile-libbz2_so || die "cannot replace -soname with -h"
		sed -i -e 's,-fpic,,' -e 's,-fPIC,,' Makefile-libbz2_so || die "cannot replace pic options"
	fi
}

bemake() {
	emake \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		"$@" || die
}
src_compile() {
	local checkopts=
	case "${CHOST}" in
		*-darwin*)
			bemake PREFIX="${EPREFIX}"/usr -f Makefile-libbz2_dylib || die
		;;
		*-mint*)
			# do nothing, no shared libraries
			:
		;;
		*)
			bemake -f Makefile-libbz2_so all || die
		;;
	esac
	use static && append-flags -static
	bemake all || die
}

src_install() {
	make PREFIX="${D}${EPREFIX}"/usr LIBDIR="$(get_libdir)" install || die
	dodoc README* CHANGES bzip2.txt manual.*

	if [[ $(get_libname) != ".irrelevant" ]] ; then

	# Install the shared lib manually.  We install:
	#  .x.x.x - standard shared lib behavior
	#  .x.x   - SONAME some distros use #338321
	#  .x     - SONAME Gentoo uses
	dolib.so libbz2$(get_libname ${PV}) || die
	local s
	for v in libbz2$(get_libname) libbz2$(get_libname ${PV%%.*}) libbz2$(get_libname ${PV%.*}) ; do
		dosym libbz2$(get_libname ${PV}) /usr/$(get_libdir)/${v} || die
	done
	gen_usr_ldscript -a bz2

	if ! use static ; then
		newbin bzip2-shared bzip2 || die
	fi
	if ! use static-libs ; then
		rm -f "${ED}"/usr/lib*/libbz2.a || die
	fi

	fi

	# move "important" bzip2 binaries to /bin and use the shared libbz2.so
	dodir /bin
	mv "${ED}"/usr/bin/b{zip2,zcat,unzip2} "${ED}"/bin/ || die
	dosym bzip2 /bin/bzcat || die
	dosym bzip2 /bin/bunzip2 || die

	if [[ ${CHOST} == *-winnt* ]]; then
		dolib.so libbz2$(get_libname ${PV}).dll || die "dolib shared"

		# on windows, we want to continue using bzip2 from interix.
		# building bzip2 on windows gives the libraries only!
		rm -rf "${ED}"/bin "${ED}"/usr/bin
	fi
}
