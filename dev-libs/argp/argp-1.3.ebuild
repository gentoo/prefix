# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit multilib

DESCRIPTION="Standalone version of arguments parsing functions from GLIBC"
HOMEPAGE="http://www.lysator.liu.se/~nisse/misc"
SRC_URI="http://www.lysator.liu.se/~nisse/misc/argp-standalone-1.3.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${PN}-standalone-${PV}

src_install() {
	mkdir -p "${ED}"/usr/$(get_libdir)
	mkdir -p "${ED}"/usr/include

	cp libargp.a "${ED}"/usr/$(get_libdir)/ || die
	cp argp.h "${ED}"/usr/include/ || die
}
