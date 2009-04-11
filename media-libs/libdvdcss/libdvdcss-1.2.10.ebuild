# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdcss/libdvdcss-1.2.10.ebuild,v 1.1 2008/08/29 21:50:30 aballier Exp $

inherit eutils autotools

DESCRIPTION="A portable abstraction library for DVD decryption"
HOMEPAGE="http://www.videolan.org/developers/libdvdcss.html"
SRC_URI="http://www.videolan.org/pub/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e 's:noinst_PROGRAMS:check_PROGRAMS:' \
		"${S}"/test/Makefile.am \
		|| die "unable to disable tests building"

	eautoreconf
}

src_compile() {
	# See bug #98854, requires access to fonts cache for TeX
	# No need to use addwrite, just set TeX font cache in the sandbox
	use doc && export VARTEXFONTS="${T}/fonts"

	econf \
		--enable-static --enable-shared \
		$(use_enable doc) \
		--disable-dependency-tracking || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog NEWS README
	use doc && dohtml doc/html/*
	use doc && dodoc doc/latex/refman.ps
}
