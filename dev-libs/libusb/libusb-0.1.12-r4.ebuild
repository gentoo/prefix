# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/libusb-0.1.12-r4.ebuild,v 1.1 2008/06/25 03:25:44 robbat2 Exp $

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"
inherit eutils libtool autotools toolchain-funcs

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI="mirror://sourceforge/libusb/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug doc nocxx"
RESTRICT="test"

RDEPEND=""
DEPEND="doc? ( app-text/openjade
	app-text/docbook-dsssl-stylesheets
	app-text/docbook-sgml-utils
	~app-text/docbook-sgml-dtd-4.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:-Werror::' Makefile.am
	sed -i 's:AC_LANG_CPLUSPLUS:AC_PROG_CXX:' configure.in #213800
	epatch "${FILESDIR}"/${PV}-fbsd.patch
	use nocxx && epatch "${FILESDIR}"/${PN}-0.1.12-nocpp.patch
	epatch "${FILESDIR}"/${PN}-0.1.12-no-infinite-bulk.patch
	eautoreconf
	elibtoolize

	# Ensure that the documentation actually finds the DTD it needs
	docbookdtd="/usr/share/sgml/docbook/sgml-dtd-4.2/docbook.dtd"
	sysid='"-//OASIS//DTD DocBook V4.2//EN"'
	sed -r -i -e \
	"s,(${sysid}) \[\$,\1 \"${docbookdtd}\" \[,g" \
	"${S}"/doc/manual.sgml
}

src_compile() {
	econf \
		$(use_enable debug debug all) \
		$(use_enable doc build-docs) \
		--libdir "${EPREFIX}"/usr/$(get_libdir) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	dodir /$(get_libdir)
	mv ${ED}/usr/$(get_libdir)/*.so* ${ED}/$(get_libdir) \
		|| die "Failed to put dynamic libs in /$(get_libdir)"

	use nocxx && rm -f "${ED}"/usr/include/usbpp.h

	gen_usr_ldscript libusb.so
	use nocxx || gen_usr_ldscript libusbpp.so

	dodoc AUTHORS NEWS README || die "dodoc failed"
	if use doc ; then
		dohtml doc/html/*.html || die "dohtml failed"
	fi
}
