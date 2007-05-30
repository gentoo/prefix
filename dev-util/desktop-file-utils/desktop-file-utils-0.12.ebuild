# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/desktop-file-utils/desktop-file-utils-0.12.ebuild,v 1.7 2007/05/24 05:15:13 jer Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Command line utilities to work with desktop menu entries"
HOMEPAGE="http://www.freedesktop.org/software/desktop-file-utils/"
SRC_URI="http://www.freedesktop.org/software/desktop-file-utils/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6.0"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# patch that disables auto pre-compiling of emacs mode file.
	epatch "${FILESDIR}"/${PN}-0.12-noemacs.patch

	# add the man pages, see bug #85354
	epatch "${FILESDIR}"/${PN}-0.10-man.patch
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
	doman man/*
}
