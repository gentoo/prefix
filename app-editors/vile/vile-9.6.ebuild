# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vile/vile-9.6.ebuild,v 1.2 2009/07/20 10:53:21 flameeyes Exp $

inherit eutils flag-o-matic

DESCRIPTION="VI Like Emacs -- yet another full-featured vi clone"
HOMEPAGE="http://invisible-island.net/vile/"
SRC_URI="ftp://invisible-island.net/vile/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="perl"

RDEPEND=">=sys-libs/ncurses-5.2
	perl? ( dev-lang/perl )"
DEPEND="${RDEPEND}
	sys-devel/flex
	app-admin/eselect-vi"

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-libs -liconv

	econf \
		--with-ncurses \
		$(use_with perl ) \
		|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	# bug #278415
	emake -j1 DESTDIR="${D}" install || die "install failed"
	dodoc CHANGES* README* doc/*
}

pkg_postinst() {
	einfo "Setting /usr/bin/vi symlink"
	eselect vi set "${PN}"
}

pkg_postrm() {
	einfo "Updating /usr/bin/vi symlink"
	eselect vi update
}
