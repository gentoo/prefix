# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gdb-apple/gdb-apple-960.ebuild,v 1.1 2009/06/21 10:38:25 grobian Exp $

inherit eutils flag-o-matic

DESCRIPTION="Apple branch of the GNU Debugger, Xcode Tools 3.1"
HOMEPAGE="http://sources.redhat.com/gdb/"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/gdb-${PV}.tar.gz"

LICENSE="APSL-2 GPL-2"
SLOT="0"

KEYWORDS="~ppc-macos ~x86-macos"

IUSE="nls"

RDEPEND=">=sys-libs/ncurses-5.2-r2
	=dev-db/sqlite-3*"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/gdb-${PV}/src

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-768-texinfo.patch
	epatch "${FILESDIR}"/${PN}-768-darwin-arch.patch

	# for FSF gcc / gcc-apple:42
	sed -e 's/-Wno-long-double//' -i gdb/config/*/macosx.mh
}

src_compile() {
	replace-flags -O? -O2
	econf \
		--disable-werror \
		$(use_enable nls) \
		|| die
	emake || die
}

src_install() {
	local ED=${ED-${D}}

	emake DESTDIR="${D}" libdir=/nukeme includedir=/nukeme install || die
	rm -r "$D"/nukeme || die
	rm -Rf "${ED}"/usr/${CHOST} || die
	mv "${ED}"/usr/bin/gdb ${ED}/
	rm -f "${ED}"/usr/bin/*
	mv "${ED}"/gdb "${ED}"/usr/bin/
}
