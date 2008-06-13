# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/db/db-1.85-r3.ebuild,v 1.13 2007/11/19 06:48:19 kumba Exp $

EAPI="prefix"

inherit eutils toolchain-funcs multilib

DESCRIPTION="old berk db kept around for really old packages"
HOMEPAGE="http://www.sleepycat.com/"
SRC_URI="ftp://ftp.sleepycat.com/releases/db.${PV}.tar.gz
	mirror://gentoo/${PF}.1.patch.bz2"

LICENSE="DB"
SLOT="1"
KEYWORDS=""
IUSE=""

DEPEND=""

S=${WORKDIR}/db.${PV}

get_port() {
	local port
	case ${CHOST} in
		*-aix*)     port=aix.3.2 ;;
		*)          port=linux ;;
	esac
	echo $port
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${PF}.1.patch
	epatch "${FILESDIR}"/${P}-gentoo-paths.patch
	sed -i \
		-e "s:@GENTOO_LIBDIR@:$(get_libdir):" \
		PORT/$(get_port)/Makefile || die
}

src_compile() {
	tc-export CC AR RANLIB
	emake -C PORT/$(get_port) OORG="${CFLAGS}" || die
}

src_install() {
	make -C PORT/$(get_port) install DESTDIR="${D}" || die

	# binary compat symlink
	dosym libdb1$(get_libname 2) /usr/$(get_libdir)/libdb$(get_libname 2) || die

	dosed "s:<db.h>:<db1/db.h>:" /usr/include/db1/ndbm.h
	dosym db1/ndbm.h /usr/include/ndbm.h

	dodoc changelog README
	newdoc hash/README README.hash
	docinto ps
	dodoc docs/*.ps
}
