# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bzip2/bzip2-1.0.3-r6.ebuild,v 1.13 2006/07/01 17:33:09 kanaka Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs flag-o-matic

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SRC_URI="http://www.bzip.org/${PV}/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="build static"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.0.2-bzgrep.patch
	epatch "${FILESDIR}"/${PN}-1.0.2-NULL-ptr-check.patch
	epatch "${FILESDIR}"/${P}-makefile-CFLAGS.patch
	epatch "${FILESDIR}"/${P}-saneso.patch
	epatch "${FILESDIR}"/${P}-shared-largefile-support.patch
	epatch "${FILESDIR}"/${PN}-1.0.2-progress.patch
	epatch "${FILESDIR}"/${PN}-1.0.2-chmod.patch
	epatch "${FILESDIR}"/${P}-no-test.patch
	epatch "${FILESDIR}"/${P}-dylib.patch
	epatch "${FILESDIR}"/${P}-makefile-LDFLAGS.patch #126826
	sed -i -e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' Makefile || die "sed manpath"

	# - Generate symlinks instead of hardlinks
	# - pass custom variables to control libdir
	sed -i \
		-e 's:ln $(PREFIX)/bin/:ln -s :' \
		-e 's:$(PREFIX)/lib:$(PREFIX)/$(LIBDIR):g' \
		Makefile || die "sed links"
}

src_compile() {
	local makeopts="
		CC=$(tc-getCC)
		AR=$(tc-getAR)
		RANLIB=$(tc-getRANLIB)
	"
	if ! use build ; then
		if [[ ${USERLAND} == "Darwin" ]] ; then
			emake ${makeopts} PREFIX="${EPREFIX}"/usr/lib libbz2.dylib
		else
			emake ${makeopts} -f Makefile-libbz2_so all || die "Make failed libbz2"
		fi
	fi
	use static && append-flags -static
	emake LDFLAGS="${LDFLAGS}" ${makeopts} all || die "Make failed"

	if ! tc-is-cross-compiler ; then
		make check || die "test failed"
	fi
}

src_install() {
	if ! use build ; then
		make PREFIX="${D}"/usr LIBDIR="$(get_libdir)" install || die

		# move bzip2 binaries to /bin and use the shared libbz2.so
		mkdir -p "${D}"/bin
		mv "${D}"/usr/bin/* "${D}"/bin/
		into /

		if use userland_Darwin ; then
			make PREFIX="${D}"/usr LIBDIR="$(get_libdir)" install-dylib \
				|| die "install-dylib failed"
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

		dodoc README* CHANGES Y2K_INFO bzip2.txt manual.*
	else
		into /
		dobin bzip2 || die "dobin bzip2"
	fi

	dosym bzip2 /bin/bzcat
	dosym bzip2 /bin/bunzip2
}
