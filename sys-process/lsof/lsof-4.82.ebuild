# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.82.ebuild,v 1.9 2010/02/01 17:58:35 hwoarang Exp $

inherit flag-o-matic toolchain-funcs eutils

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
	epatch "${FILESDIR}"/${PN}-4.81-aix.patch #278831

	sed -i \
		-e '/LSOF_CFGF="-/s:=":="$LSOF_CFGF :' \
		-e '/^LSOF_CFGF=/s:$:" ${CFLAGS} ${CPPFLAGS}":' \
		-e "/^LSOF_CFGL=/s:\$:' \$(LDFLAGS)':" \
		-e "/^LSOF_RANLIB/s:ranlib:$(tc-getRANLIB):" \
		Configure

	epatch "${FILESDIR}"/${P}-config-solaris.patch
	epatch "${FILESDIR}"/${PN}-4.80-solaris11.patch
	if [[ ${CHOST} == *-solaris2.11 ]] ; then
		mkdir -p ext/sys
		# missing system header :(
		cp "${FILESDIR}"/solaris11-extdirent.h ext/sys/extdirent.h
		( cd lib && ln -s ../ext )
	fi
}

yesno() { use $1 && echo y || echo n ; }
target() {
	case ${CHOST} in
		*-darwin*)  echo darwin  ;;
		*-freebsd*) echo freebsd ;;
		*-solaris*) echo solaris ;;
		*-aix*)     echo aixgcc  ;;
		*)          echo linux   ;;
	esac
}
ar() {
	case ${CHOST} in
		*-aix*)     echo "ar -X32_64 -v -q" ;;
		*)          echo "$(tc-getAR) rc"   ;;
	esac
}

src_compile() {
	use static && append-ldflags -static

	touch .neverInv
	touch .neverCust
	LINUX_HASSELINUX=$(yesno selinux) \
	LSOF_CC=$(tc-getCC) \
	LSOF_AR="$(ar)" \
	./Configure -n $(target) < /dev/null || die

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
