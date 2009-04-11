# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/snack/snack-2.2.10-r1.ebuild,v 1.9 2008/08/08 16:55:30 armin76 Exp $

inherit eutils multilib

DESCRIPTION="The Snack Sound Toolkit (Tcl)"
HOMEPAGE="http://www.speech.kth.se/snack/"
SRC_URI="http://www.speech.kth.se/snack/dist/${PN}${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
SLOT="0"
IUSE="alsa examples python threads vorbis"

RESTRICT="test" # Bug 78354

DEPEND=">dev-lang/tcl-8.4.3
	>dev-lang/tk-8.4.3
	alsa? ( media-libs/alsa-lib )
	vorbis? ( media-libs/libvorbis )
	python? ( virtual/python )"

S="${WORKDIR}/${PN}${PV}/unix"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	local myconf="--libdir="${EPREFIX}"/usr/$(get_libdir) --includedir="${EPREFIX}"/usr/include"

	use alsa && myconf="${myconf} --enable-alsa"
	use threads && myconf="${myconf} --enable-threads"

	if use vorbis ; then
		myconf="${myconf} --with-ogg-include="${EPREFIX}"/usr/include"
		myconf="${myconf} --with-ogg-lib="${EPREFIX}"/usr/$(get_libdir)"
	fi

	econf ${myconf} || die "configure failed"
	emake || die "make failed"

}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use python ; then
		cd "${S}"/../python
		python setup.py install --root="${ED}" || die
	fi

	cd "${S}"/..

	dodoc README changes
	dohtml doc/*

	if use examples ; then
		sed -i -e 's/wish[0-9.]+/wish/g' demos/tcl/* || die
		docinto examples/tcl
		dodoc demos/tcl/*

		if use python ; then
			docinto examples/python
			dodoc demos/python/*
		fi
	fi
}
