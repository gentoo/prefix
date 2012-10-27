# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.86.ebuild,v 1.1 2012/09/04 20:36:08 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs

MY_P=${P/-/_}
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/"
SRC_URI="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://vic.cc.purdue.edu/pub/tools/unix/lsof/${MY_P}.tar.bz2
	ftp://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/${MY_P}.tar.bz2"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="examples ipv6 rpc selinux static"

RDEPEND="rpc? ( net-libs/libtirpc )
	selinux? ( sys-libs/libselinux )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}/${MY_P}_src

src_unpack() {
	unpack ${A}
	cd ${MY_P}
	unpack ./${MY_P}_src.tar
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.85-cross.patch #432120
	# convert `test -r header.h` into a compile test
	sed -i -r \
		-e 's:test -r \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\1>" | ${LSOF_CC} ${LSOF_CFGF} -E - >/dev/null 2>\&1:' \
		-e 's:grep (.*) \$\{LSOF_INCLUDE\}/([[:alnum:]/._]*):echo "#include <\2>" | ${LSOF_CC} ${LSOF_CFGF} -E -P -dD - 2>/dev/null | grep \1:' \
		Configure || die

	epatch "${FILESDIR}"/${PN}-4.81-aix.patch #278831
}

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
src_configure() {
	use static && append-ldflags -static

	append-cppflags $(usex rpc "$($(tc-getPKG_CONFIG) libtirpc --cflags)" "-DHASNOTRPC -DHASNORPC_H")
	append-cppflags $(usex ipv6 -{D,U}HASIPv6)

	export LSOF_CFGL="${CFLAGS} ${LDFLAGS} \
		$(use rpc && $(tc-getPKG_CONFIG) libtirpc --libs)"

	# Set LSOF_INCLUDE to a dummy location so the script doesn't poke
	# around in it and mix /usr/include paths with cross-compile/etc.
	# except that is breaks Darwin badly
	touch .neverInv
	touch .neverCust
	LINUX_HASSELINUX=$(usex selinux y n) \
	LSOF_INCLUDE=$([[ ${CHOST} == *-darwin* ]] && echo "" || echo ${T}) \
	LSOF_CC=$(tc-getCC) \
	LSOF_AR="$(ar)" \
	LSOF_RANLIB=$(tc-getRANLIB) \
	LSOF_CFGF="${CFLAGS} ${CPPFLAGS}" \
	./Configure -n $(target) < /dev/null || die
}

src_compile() {
	emake DEBUG="" all || die
}

src_install() {
	dobin lsof || die

	if use examples ; then
		insinto /usr/share/lsof/scripts
		doins scripts/* || die
	fi

	doman lsof.8 || die
	dodoc 00*
}

pkg_postinst() {
	if [[ ${CHOST} == *-solaris* ]] ; then
		einfo "Note: to use lsof on Solaris you need read permissions on"
		einfo "/dev/kmem, i.e. you need to be root, or to be in the group sys"
	fi
}
