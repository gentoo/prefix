# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-1.95.8.ebuild,v 1.20 2006/09/06 18:19:56 flameeyes Exp $

EAPI="prefix"

inherit libtool multilib

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="test"

DEPEND="test? ( >=dev-libs/check-0.8 )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

src_test() {
	if ! use test && [[ -z $(best_version dev-libs/check) ]] ; then
		ewarn "You dont have USE=test and dev-libs/check is not installed."
		ewarn "src_test will be skipped."
		return 0
	fi
	make check || die "make check failed"
}

src_install() {
	# make install is heavily broken and wants to deliberately install
	# into the wrong locations...
	make \
		DESTDIR="${ED}" \
		mandir="${ED}/usr/share/man" \
		libdir="${ED}/${EPREFIX}/usr/$(get_libdir)" \
		install || die "einstall failed"
	dosed /usr/$(get_libdir)/libexpat.la #81568
	dodoc Changes README
	dohtml doc/*
}
