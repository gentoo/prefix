# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.80-r1.ebuild,v 1.1 2008/10/03 16:50:46 flameeyes Exp $

inherit eutils flag-o-matic fixheadtails toolchain-funcs

MY_P=${P/-/_}
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/"
SRC_URI="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://vic.cc.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/${MY_P}.tar.bz2"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
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
	epatch "${FILESDIR}"/${PN}-4.78-answer-config.patch
	epatch "${FILESDIR}"/${PN}-4.78-config-solaris.patch
	epatch "${FILESDIR}"/${PN}-4.80-solaris11.patch
	if [[ ${CHOST} == *-solaris2.11 ]] ; then
		mkdir -p ext/sys
		# missing system header :(
		cp "${FILESDIR}"/solaris11-extdirent.h ext/sys/extdirent.h
		( cd lib && ln -s ../ext )
	fi
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
	case ${CHOST} in
	*-solaris*) target=solaris ;;
	*-aix*) target=aixgcc; export LSOF_AR='ar -X32_64 -v -q' ;;
	esac
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

	insinto /usr/share/lsof/scripts
	doins scripts/*

	doman lsof.8
	dodoc 00*
}
