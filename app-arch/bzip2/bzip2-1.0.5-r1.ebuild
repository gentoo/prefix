# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bzip2/bzip2-1.0.5-r1.ebuild,v 1.7 2008/09/22 04:02:26 jer Exp $

inherit eutils multilib toolchain-funcs flag-o-matic prefix

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SRC_URI="http://www.bzip.org/${PV}/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.0.4-makefile-CFLAGS.patch
	epatch "${FILESDIR}"/${PN}-1.0.4-saneso.patch
	epatch "${FILESDIR}"/${PN}-1.0.4-man-links.patch #172986
	epatch "${FILESDIR}"/${PN}-1.0.2-progress.patch
	epatch "${FILESDIR}"/${PN}-1.0.3-no-test.patch
	epatch "${FILESDIR}"/${PN}-1.0.4-POSIX-shell.patch #193365
	epatch "${FILESDIR}"/${PN}-1.0.5-soldflags.patch # for AIX, HP-UX
	epatch "${FILESDIR}"/${PN}-1.0.5-checkenv.patch # for AIX, Darwin?
	epatch "${FILESDIR}"/${PN}-1.0.4-prefix.patch
	eprefixify bz{diff,grep,more}
	sed -i -e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' Makefile || die "sed manpath"
	# this a makefile for Darwin, which already "includes" saneso
	cp "${FILESDIR}"/${P}-Makefile-libbz2_dylib Makefile-libbz2_dylib || die

	# - Generate symlinks instead of hardlinks
	# - pass custom variables to control libdir
	sed -i \
		-e 's:ln -s -f $(PREFIX)/bin/:ln -s :' \
		-e 's:$(PREFIX)/lib:$(PREFIX)/$(LIBDIR):g' \
		Makefile || die "sed links"

	# fixup broken version stuff
	sed -i \
		-e "s:1\.0\.4:${PV}:" \
		bzip2.1 bzip2.txt Makefile-libbz2_so manual.{html,ps,xml} || die

	if [[ ${CHOST} == *-hpux* ]] ; then
		sed -i -e 's,-soname,+h,' Makefile-libbz2_so || die "cannot replace -soname with +h"
		if [[ ${CHOST} == hppa*-hpux* && ${CHOST} != hppa64*-hpux* ]] ; then
			sed -i -e '/^SOEXT/s,so,sl,' Makefile-libbz2_so || die "cannot replace so with sl"
			sed -i -e '/^SONAME/s,=,=${EPREFIX}/lib/,' Makefile-libbz2_so || die "cannt set soname"
		fi
	elif [[ ${CHOST} == *-interix* ]] ; then
		sed -i -e 's,-soname,-h,' Makefile-libbz2_so || die "cannot replace -soname with -h"
	fi
}

src_compile() {
	local makeopts=(
		"CC=$(tc-getCC)"
		"AR=$(tc-getAR)"
		"RANLIB=$(tc-getRANLIB)"
	)
	local checkopts=
	case "${CHOST}" in
		*-darwin*)
			emake "${makeopts[@]}" PREFIX="${EPREFIX}"/usr -f Makefile-libbz2_dylib || die "Make failed libbz2"
		;;
		*-mint*)
			# do nothing, no shared libraries
			:
		;;
		*-aix*)
			# AIX has shared object libbz2.so.1 inside libbz2.a.
			# We build libbz2.a here to avoid static-only libbz2.a below.
			emake "${makeopts[@]}" SOLDFLAGS=-shared -f Makefile-libbz2_so all || die "Make failed libbz2"
			checkopts="TESTENV=LIBPATH=."
		;;
		*)
			emake "${makeopts[@]}" -f Makefile-libbz2_so all || die "Make failed libbz2"
		;;
	esac
	use static && append-flags -static
	emake LDFLAGS="${LDFLAGS}" "${makeopts[@]}" all || die "Make failed"
}

src_install() {
	make PREFIX="${D}${EPREFIX}"/usr LIBDIR="$(get_libdir)" install || die
	dodoc README* CHANGES bzip2.txt manual.*

	# move "important" bzip2 binaries to /bin and use the shared libbz2.so
	dodir /bin
	mv "${ED}"/usr/bin/b{zip2,zcat,unzip2} "${ED}"/bin/ || die
	dosym bzip2 /bin/bzcat
	dosym bzip2 /bin/bunzip2
	into /

	if [[ $(get_libname) != ".irrelevant" ]] ; then

	if ! use static ; then
		newbin bzip2-shared bzip2 || die "dobin shared"
	fi

	dolib.so libbz2$(get_libname ${PV}) || die "dolib shared"
	if [[ ${CHOST} == *-winnt* ]]; then
		dolib.so libbz2$(get_libname ${PV}).dll || die "dolib shared"

		# on windows, we want to continue using bzip2 from interix.
		# building bzip2 on windows gives the libraries only!
		rm -rf "${ED}"/bin "${ED}"/usr/bin
	fi
	for v in libbz2$(get_libname) libbz2$(get_libname ${PV%%.*}) libbz2$(get_libname ${PV%.*}) ; do
		[[ libbz2$(get_libname ${PV}) != ${v} ]] &&
		dosym libbz2$(get_libname ${PV}) /$(get_libdir)/${v}
	done
	gen_usr_ldscript libbz2$(get_libname)

	fi
}
