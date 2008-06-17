# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdcss/libdvdcss-1.2.9-r1.ebuild,v 1.14 2008/06/16 11:31:15 flameeyes Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="A portable abstraction library for DVD decryption"
HOMEPAGE="http://www.videolan.org/developers/libdvdcss.html"
SRC_URI="http://www.videolan.org/pub/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

pkg_preinst() {
	# these could cause problems if they exist from
	# earlier builds
	for x in libdvdcss.so.0 libdvdcss.so.1 libdvdcss.0.dylib libdvdcss.1.dylib ; do
		if [[ -e ${EROOT}/usr/$(get_libdir)/${x} ]] ; then
			rm -f "${EROOT}"/usr/$(get_libdir)/${x}
		fi
	done
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# add configure switches to enable/disable doc building
	epatch "${FILESDIR}"/${P}-doc.patch

	# Fix character encoding from 8859-15 to utf8
	epatch "${FILESDIR}/${P}-latex-character-encoding.patch"

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
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog NEWS README
	use doc && dohtml doc/html/*
	use doc && dodoc doc/latex/refman.ps
}
