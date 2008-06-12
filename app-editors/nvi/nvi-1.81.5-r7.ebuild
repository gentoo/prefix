# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/nvi/nvi-1.81.5-r7.ebuild,v 1.3 2007/10/10 07:14:58 opfer Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Vi clone"
HOMEPAGE="http://www.bostic.com/vi/"
SRC_URI="http://www.kotnet.org/~skimo/nvi/devel/${P}.tar.gz"

LICENSE="Sleepycat"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="perl unicode"

DEPEND="=sys-libs/db-4*"
RDEPEND="${DEPEND}
	app-admin/eselect-vi"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	# Fix bug 23888
	epatch "${FILESDIR}"/${P}-tcsetattr.patch
	# Fix bug 150169
	epatch "${FILESDIR}"/${P}-wide.patch
	epatch "${FILESDIR}"/${P}-wide-2.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-db4.patch
	epatch "${FILESDIR}"/${P}-header.patch
	epatch "${FILESDIR}"/${P}-darwin-sys5-pty.patch
	epatch "${FILESDIR}"/${P}-darwin.patch
	touch "${S}"/dist/{configure,aclocal.m4,Makefile.in,stamp-h.in}
}

src_compile() {
	local myconf

	use perl && myconf="${myconf} --enable-perlinterp"
	use unicode && myconf="${myconf} --enable-widechar"

	cd build.unix
	ECONF_SOURCE=../dist econf \
		--program-prefix=n \
		${myconf} \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	cd build.unix
	emake -j1 DESTDIR="${D}" install || die "install failed"
}

pkg_postinst() {
	einfo "Setting /usr/bin/vi symlink"
	eselect vi update --if-unset
}

pkg_postrm() {
	einfo "Updating /usr/bin/vi symlink"
	eselect vi update --if-unset
}
