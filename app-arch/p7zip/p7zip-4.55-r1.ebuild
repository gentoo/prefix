# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/p7zip/p7zip-4.55-r1.ebuild,v 1.4 2008/01/26 14:22:32 ranger Exp $

EAPI="prefix"

inherit eutils toolchain-funcs multilib

DESCRIPTION="Port of 7-Zip archiver for Unix"
HOMEPAGE="http://p7zip.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_src_all.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static doc"

DEPEND=""

S=${WORKDIR}/${PN}_${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "/^CXX=/s:g++:$(tc-getCXX):" \
		-e "/^CC=/s:gcc:$(tc-getCC):" \
		-e "s:OPTFLAGS=-O:OPTFLAGS=${CXXFLAGS}:" \
		-e 's:-s ::' \
		makefile* || die "changing makefiles"

	if use amd64; then
		ewarn "Using suboptimal -fPIC upstream makefile due to amd64 being detected. See #126722"
		cp -f makefile.linux_amd64 makefile.machine
	elif [[ ${CHOST} == *-darwin* ]] ; then
		# Mac OS X needs this special makefile, because it has a non-GNU linker
		cp -f makefile.macosx makefile.machine
	elif use x86-fbsd; then
		# FreeBSD needs this special makefile, because it hasn't -ldl
		sed -e 's/-lc_r/-pthread/' makefile.freebsd > makefile.machine
	fi
	use static && sed -i -e '/^LOCAL_LIBS=/s/LOCAL_LIBS=/&-static /' makefile.machine
}

src_compile() {
	emake all3 || die "compilation error"
}

src_install() {
	# this wrappers can not be symlinks, p7zip should be called with full path
	make_wrapper 7zr "/usr/lib/${PN}/7zr"
	make_wrapper 7za "/usr/lib/${PN}/7za"
	make_wrapper 7z "/usr/lib/${PN}/7z"

	dobin "${FILESDIR}/p7zip" || die

	# gzip introduced in 4.42, so beware :)
	# mv needed just as rename, because dobin installs using old name
	mv contrib/gzip-like_CLI_wrapper_for_7z/p7zip contrib/gzip-like_CLI_wrapper_for_7z/7zg || die
	dobin contrib/gzip-like_CLI_wrapper_for_7z/7zg || die

	exeinto /usr/$(get_libdir)/${PN}
	doexe bin/7z bin/7za bin/7zr bin/7zCon.sfx || die "doexe bins"
	exeinto /usr/$(get_libdir)/${PN}/Codecs
	doexe bin/Codecs/* || die "doexe Codecs"
	exeinto /usr/$(get_libdir)/${PN}
	doexe bin/*.so || die "doexe *.so files"

	doman man1/7z.1 man1/7za.1 man1/7zr.1
	dodoc ChangeLog README TODO

	if use doc ; then
		dodoc DOCS/*.txt
		dohtml -r DOCS/MANUAL/*
	fi
}
