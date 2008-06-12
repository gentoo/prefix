# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bzip2/bzip2-1.0.4-r1.ebuild,v 1.8 2008/03/21 05:14:22 vapier Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs flag-o-matic

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SRC_URI="http://www.bzip.org/${PV}/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
	epatch "${FILESDIR}"/${PN}-1.0.3-dylib.patch # for Darwin
	epatch "${FILESDIR}"/${PN}-1.0.4-soldflags.patch # for AIX
	epatch "${FILESDIR}"/${PN}-1.0.4-prefix.patch
	eprefixify bz{diff,grep,more}
	sed -i -e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' Makefile || die "sed manpath"

	# - Generate symlinks instead of hardlinks
	# - pass custom variables to control libdir
	sed -i \
		-e 's:ln -s -f $(PREFIX)/bin/:ln -s :' \
		-e 's:$(PREFIX)/lib:$(PREFIX)/$(LIBDIR):g' \
		Makefile || die "sed links"

	if [[ ${CHOST} = *-hpux* ]]; then
		sed -i -e 's,-soname,+h,' Makefile-libbz2_so || die "cannot replace -soname with +h"
	fi
}

src_compile() {
	local makeopts="
		CC=$(tc-getCC)
		AR=$(tc-getAR)
		RANLIB=$(tc-getRANLIB)
	"
	case "${CHOST}" in
		*-darwin*)
			emake ${makeopts} PREFIX="${EPREFIX}"/usr/lib libbz2.dylib || die "Make failed libbz2"
		;;
		*-aix*)
			emake ${makeopts} SOLDFLAGS=-shared -f Makefile-libbz2_so all || die "Make failed libbz2"
		;;
		*)
			emake ${makeopts} -f Makefile-libbz2_so all || die "Make failed libbz2"
		;;
	esac
	use static && append-flags -static
	emake LDFLAGS="${LDFLAGS}" ${makeopts} all || die "Make failed"

	if ! tc-is-cross-compiler ; then
		make check || die "test failed"
	fi
}

src_install() {
	make PREFIX="${D}${EPREFIX}"/usr LIBDIR="$(get_libdir)" install || die

	# move bzip2 binaries to /bin and use the shared libbz2.so
	mkdir -p "${ED}"/bin
	mv "${ED}"/usr/bin/* "${ED}"/bin/
	into /

	if [[ ${CHOST} == *-darwin* ]] ; then
		make PREFIX="${D}${EPREFIX}"/usr LIBDIR="$(get_libdir)" install-dylib \
			|| die "install-dylib failed"
		dodir $(get_libdir)
		mv "${ED}"/usr/$(get_libdir)/*.dylib "${ED}"/$(get_libdir)/
		gen_usr_ldscript libbz2.dylib
		# fix library references
		for obj in "${ED}"/bin/bzip2 ; do
			l=$(otool -L "${obj}" | grep libbz2 | cut -d' ' -f1 | cut -f2)
			install_name_tool -change \
				"${l}" "${EPREFIX}"/lib/$(basename ${l}) \
				"${obj}"
		done
	else
		if ! use static ; then
			newbin bzip2-shared bzip2 || die "dobin shared"
		fi
		dolib.so "${S}"/libbz2.so.${PV} || die "dolib shared"
		for v in libbz2.so{,.{${PV%%.*},${PV%.*}}} ; do
			dosym libbz2.so.${PV} /$(get_libdir)/${v}
		done
		gen_usr_ldscript libbz2.so
	fi

	dodoc README* CHANGES bzip2.txt manual.*

	dosym bzip2 /bin/bzcat
	dosym bzip2 /bin/bunzip2
}
