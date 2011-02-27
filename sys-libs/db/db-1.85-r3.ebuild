# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/db/db-1.85-r3.ebuild,v 1.15 2011/02/06 21:34:37 leio Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="old berk db kept around for really old packages"
HOMEPAGE="http://www.oracle.com/technology/software/products/berkeley-db/db/index.html"
SRC_URI="http://download.oracle.com/berkeley-db/db.${PV}.tar.gz
		 mirror://gentoo/${PF}.1.patch.bz2"
# The patch used by Gentoo is from Fedora, and includes all 5 patches found on
# the Oracle page, plus others.

LICENSE="DB"
SLOT="1"
KEYWORDS="~x64-macos"
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
