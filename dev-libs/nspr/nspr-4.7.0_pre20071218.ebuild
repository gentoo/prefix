# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nspr/nspr-4.7.0_pre20071218.ebuild,v 1.1 2007/12/22 18:18:59 armin76 Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs

DESCRIPTION="Netscape Portable Runtime"
HOMEPAGE="http://www.mozilla.org/projects/nspr/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc-solaris ~x86"
IUSE="ipv6 debug"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	mkdir build inst
	epatch "${FILESDIR}"/${PN}-4.6.1-config.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-config-1.patch
	epatch "${FILESDIR}"/${PN}-4.6.1-lang.patch
	epatch "${FILESDIR}"/${PN}-4.7.0-prtime.patch
}

src_compile() {
	cd "${S}"/build

	if use amd64 || use ppc64 || use ia64 || use s390; then
		myconf="${myconf} --enable-64bit"
	else
		myconf=""
	fi

	if use ipv6; then
		myconf="${myconf} --enable-ipv6"
	fi

	myconf="${myconf} --libdir=${EPREFIX}/usr/$(get_libdir)/nspr"

	ECONF_SOURCE="../mozilla/nsprpub" CC=$(tc-getCC) CXX=$(tc-getCPP) econf \
		$(use_enable debug) \
		${myconf} || die "econf failed"
	make || die
}

src_install () {
	# Their build system is royally fucked, as usual
	MINOR_VERSION=7
	cd "${S}"/build
	emake DESTDIR="${D}" install || die "emake install failed"

	cd "${ED}"/usr/$(get_libdir)/nspr
	for file in *.so; do
		mv ${file} ${file}.${MINOR_VERSION}
		ln -s ${file}.${MINOR_VERSION} ${file}
	done
	# cope with libraries being in /usr/lib/nspr
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/nspr" > "${ED}/etc/env.d/08nspr"

	# install nspr-config
	dobin "${S}"/build/config/nspr-config

	# create pkg-config file
	insinto /usr/$(get_libdir)/pkgconfig/
	doins "${S}"/build/config/nspr.pc

	# Remove stupid files in /usr/bin
	rm "${ED}"/usr/bin/{prerr.properties,nspr.pc}
}
