# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-utils/docbook-sgml-utils-0.6.14.ebuild,v 1.29 2007/07/12 09:22:18 uberlord Exp $

EAPI="prefix"

inherit eutils autotools

MY_PN=${PN/-sgml/}
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Shell scripts to manage DocBook documents"
HOMEPAGE="http://sources.redhat.com/docbook-tools/"
SRC_URI="ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="tetex"

DEPEND=">=dev-lang/perl-5
	app-text/docbook-dsssl-stylesheets
	app-text/openjade
	dev-perl/SGMLSpm
	~app-text/docbook-xml-simple-dtd-4.1.2.4
	~app-text/docbook-xml-simple-dtd-1.0
	app-text/docbook-xml-dtd
	~app-text/docbook-sgml-dtd-3.0
	~app-text/docbook-sgml-dtd-3.1
	~app-text/docbook-sgml-dtd-4.0
	~app-text/docbook-sgml-dtd-4.1
	tetex? ( app-text/jadetex )
	userland_GNU? ( sys-apps/which )
	|| (
		www-client/lynx
		www-client/links
		www-client/elinks
		virtual/w3m )"

# including both xml-simple-dtd 4.1.2.4 and 1.0, to ease
# transition to simple-dtd 1.0, <obz@gentoo.org>

src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch "${FILESDIR}"/${MY_P}-elinks.patch
	epatch "${FILESDIR}"/${MY_P}-prefix.patch
	eprefixify doc/{man,HTML}/Makefile.am bin/jw.in backends/txt configure.in
	eautoreconf
}

src_install() {
	make DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		install || die "Installation failed"

	if ! use tetex ; then
		for i in dvi pdf ps ; do
			rm "${ED}"/usr/bin/docbook2$i
			rm "${ED}"/usr/share/sgml/docbook/utils-${PV}/backends/$i
			rm "${ED}"/usr/share/man/man1/docbook2$i.1
		done
	fi
	dodoc AUTHORS ChangeLog NEWS README TODO
}
