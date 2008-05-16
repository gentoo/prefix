# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.78-r2.ebuild,v 1.1 2008/05/14 15:05:26 cardoe Exp $

EAPI="prefix"

inherit eutils flag-o-matic fixheadtails toolchain-funcs

MY_P=${P/-/_}
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/"
SRC_URI="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://vic.cc.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/${MY_P}.tar.bz2"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="static selinux"

DEPEND="selinux? ( sys-libs/libselinux )"

S=${WORKDIR}/${MY_P}/${MY_P}_src

src_unpack() {
	unpack ${A}
	cd ${MY_P}
	unpack ./${MY_P}_src.tar

	# now patch the scripts to automate everything
	cd "${S}"
	ht_fix_file Configure Customize
	touch .neverInv
	epatch "${FILESDIR}"/${P}-answer-config.patch
	epatch "${FILESDIR}"/${P}-freebsd.patch
	epatch "${FILESDIR}"/${P}-config-solaris.patch
	#Fix automagic dependency on libselinux. Bug 188272.
	if ! use selinux; then
		sed -i \
			-e 's/ -DHASSELINUX//' \
			-e 's/ -lselinux//' \
			Configure || die "Sed failed. 404. WTF..."
	fi
}

src_compile() {
	use static && append-ldflags -static

	local target="linux"
	use kernel_FreeBSD && target=freebsd
	[[ ${CHOST} == *-solaris* ]] && target=solaris
	./Configure ${target} || die "configure failed"

	# Make sure we use proper toolchain
	sed -i \
		-e "/^CC=/s:g\?cc:$(tc-getCC):" \
		-e "/^AR=/s:ar:$(tc-getAR):" \
		-e "/^RANLIB=/s:ranlib:$(tc-getRANLIB):" \
		Makefile lib/Makefile

	emake DEBUG="" all || die "emake failed"
}

src_install() {
	dobin lsof || die "dosbin"
	dolib lib/liblsof.a || die "dolib"

	insinto /usr/share/lsof/scripts
	doins scripts/*

	doman lsof.8
	dodoc 00*
}
