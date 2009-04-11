# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/net-libs/libssh/libssh-0.2.ebuild,v 1.1 2007/01/07 04:17:23 dragonheart Exp $

inherit eutils

DESCRIPTION="Access a working SSH implementation by means of a library"
HOMEPAGE="http://0xbadc0de.be/?part=libssh"
SRC_URI="http://www.0xbadc0de.be/libssh/${P}.tgz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="crypt examples"

DEPEND="sys-libs/zlib
	!crypt? ( dev-libs/openssl )
	crypt? ( dev-libs/libgcrypt )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/makefile_no-examples.diff"
}

src_compile() {
	econf \
		$(use_with crypt) \
		--disable-ssh1 \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	chmod a-x ${ED}/usr/include/libssh/*
	emake DESTDIR="${D}" install || die "install failed"
	rm "${ED}"/usr/include/libssh/ssh1.h
	dodoc README CHANGELOG
	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins sample.c samplesshd.c
	fi
}
