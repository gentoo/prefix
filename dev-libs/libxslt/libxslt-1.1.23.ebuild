# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxslt/libxslt-1.1.23.ebuild,v 1.1 2008/04/20 11:20:23 eva Exp $

inherit libtool eutils python autotools

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt debug examples python"

DEPEND=">=dev-libs/libxml2-2.6.27
	crypt?  ( >=dev-libs/libgcrypt-1.1.92 )
	python? ( dev-lang/python )"

SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# we still require the 1.1.8 patch for the .m4 file, to add
	# the CXXFLAGS defines <obz@gentoo.org>
	epatch "${FILESDIR}/libxslt.m4-${PN}-1.1.8.patch"

	# fix parallel install, bug #212784.
	epatch "${FILESDIR}/${P}-parallel-install.patch"

	# Patch Makefile to fix bug #99382 so that html gets installed in ${PF}
	sed -i -e "s:libxslt-\$(VERSION):${PF}:" doc/Makefile.am

	#eautomake
	eautoreconf # need new libtool for interix
	epunt_cxx
	elibtoolize
}

src_compile() {
	# Always pass --with-debugger. It is required by third parties (see
	# e.g. bug #98345)
	local myconf="--with-debugger \
		$(use_with python)       \
		$(use_with crypt crypto) \
		$(use_with debug)        \
		$(use_with debug mem-debug)"

	econf ${myconf} || die "configure failed"

	emake || die "Compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog Copyright FEATURES NEWS README TODO

	if ! use examples; then
		rm -rf "${ED}/usr/share/doc/${PN}-python-${PV}/examples"
	fi
}
