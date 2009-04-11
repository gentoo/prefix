# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.81-r2.ebuild,v 1.9 2009/03/17 10:22:21 armin76 Exp $

inherit eutils flag-o-matic fixheadtails toolchain-funcs

MY_P=${P/-/_}
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/"
SRC_URI="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://vic.cc.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/${MY_P}.tar.bz2"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="static selinux"

DEPEND="selinux? ( sys-libs/libselinux )"

S=${WORKDIR}/${MY_P}/${MY_P}_src

src_unpack() {
	unpack ${A}
	cd ${MY_P}
	unpack ./${MY_P}_src.tar
	cd "${S}"

	# Patch an over-zealous rejection of open-file listing when
	# no options are specified on the command line and security
	# options are enabled.  Bug #244660
	epatch "${FILESDIR}"/${P}-proc_c.patch

	# now patch the scripts to automate everything
	ht_fix_file Configure Customize
	touch .neverInv
	epatch "${FILESDIR}"/${PN}-4.78-answer-config.patch
	epatch "${FILESDIR}"/${P}-config-solaris.patch
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
	epatch "${FILESDIR}"/${P}-recmake.patch #250383 drop at next bump
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

pkg_postinst() {
	if [[ ${CHOST} == *-solaris* ]] ; then
		einfo "Note: to use lsof on Solaris you need read permissions on"
		einfo "/dev/kmem, i.e. you need to be root, or to be in the group sys"
	fi
}
