# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nspr/nspr-4.6.6.ebuild,v 1.1 2007/03/09 21:31:07 armin76 Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="Netscape Portable Runtime"
HOMEPAGE="http://www.mozilla.org/projects/nspr/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${PV}/src/${P}.tar.gz"

LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="ipv6 debug"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	mkdir build inst
	epatch "${FILESDIR}"/${PN}-4.6.1-config.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-config-1.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-lang.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-prtime.patch
}

src_compile() {
	cd build

	if use amd64 || use ppc64 || use ia64 || use s390; then
		myconf="${myconf} --enable-64bit"
	else
		myconf=""
	fi

	if use ipv6; then
		myconf="${myconf} --enable-ipv6"
	fi

	myconf="${myconf} --libdir=${EPREFIX}/usr/$(get_libdir)/nspr"

	ECONF_SOURCE="../mozilla/nsprpub" econf \
		$(use_enable debug) \
		${myconf} || die "econf failed"
	make || die
}

src_install () {
	# Their build system is royally fucked, as usual
	MINOR_VERSION=6
	cd ${S}/build
	make install
	insinto /usr
	doins -r dist/*
	rm -rf ${ED}/usr/bin/lib*.so

	#removing includes/nspr/md as per fedora spec
	# i.e a waste of space!
	rm -rf ${ED}/usr/include/nspr/md

	# there have been /usr/lib/nspr changes (like the ldpath below), but never
	# have I seen any libraries end up in this directory. lets fix that.
	# note: I tried doing this fix via the build system. It wont work.
	if [ ! -e ${ED}/usr/lib/nspr ] ; then
		mkdir -p ${ED}/usr/lib/nspr
		mv ${ED}/usr/lib/*so* ${ED}/usr/lib/nspr
		mv ${ED}/usr/lib/*\.a ${ED}/usr/lib/nspr
	fi
	# and while we're at it, lets make it actually use the arch's libdir damnit
	if [ "lib" != "$(get_libdir)" ] ; then
		mv ${ED}/usr/lib ${ED}/usr/$(get_libdir)
	fi
	#and while at it move them to files with versions-ending
	#and link them back :)
	cd ${ED}/usr/$(get_libdir)/nspr
	for file in *.so; do
		mv ${file} ${file}.${MINOR_VERSION}
		ln -s ${file}.${MINOR_VERSION} ${file}
	done
	# cope with libraries being in /usr/lib/nspr
	dodir /etc/env.d
	echo "LDPATH=/usr/$(get_libdir)/nspr" > ${ED}/etc/env.d/08nspr

	# install nspr-config
	insinto	 /usr/bin
	doins ${S}/build/config/nspr-config
	chmod a+x ${ED}/usr/bin/nspr-config

	# create pkg-config file
	insinto /usr/$(get_libdir)/pkgconfig/
	doins ${S}/build/config/nspr.pc
}
