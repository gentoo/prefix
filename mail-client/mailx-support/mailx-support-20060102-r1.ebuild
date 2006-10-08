# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/mailx-support/mailx-support-20060102-r1.ebuild,v 1.2 2006/07/03 01:43:00 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Provides mail.local and lockspool"
HOMEPAGE="http://www.openbsd.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""
SRC_URI="mirror://gentoo/${P}.tar.bz2"
DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/${P}-respect-ldflags.patch"
	ebegin "Allowing unprivileged install"
	sed -i \
		-e "s|-g 0 -o 0||g" \
		Makefile
	eend $?
}

src_compile() {
	emake CC="$(tc-getCC)" BINDNOW_FLAGS="$(bindnow-flags)" || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"
}
