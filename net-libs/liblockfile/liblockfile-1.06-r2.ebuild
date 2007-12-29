# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/liblockfile/liblockfile-1.06-r2.ebuild,v 1.12 2007/12/28 23:28:07 welp Exp $

EAPI="prefix"

inherit eutils multilib flag-o-matic autotools

DESCRIPTION="Implements functions designed to lock the standard mailboxes"
HOMEPAGE="http://www.debian.org/"
SRC_URI="mirror://debian/pool/main/libl/${PN}/${PN}_${PV}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-fbsd"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-glibc24.patch
	epatch "${FILESDIR}"/${P}-respectflags.patch
	epatch "${FILESDIR}"/${PN}-orphan-file.patch

	# I didn't feel like making the Makefile portable
	[[ ${CHOST} == *-darwin* ]] \
		&& cp ${FILESDIR}/Makefile.Darwin.in Makefile.in

	# Rename an internal function so it does not conflict with
	# libc's function.
	sed -i -e 's/eaccess/egidaccess/g' *.c

	eautoreconf

	# Do not use lazy bindings on setXid files
	sed -i -e 's~-o dotlockfile~'$(bindnow-flags)' &~g' Makefile.in

}

src_compile() {
	# in privileged installs this is "mail"
	econf --with-mailgroup=`id -gn` --enable-shared || die
	emake || die
}

src_install() {
	dodir /usr/{bin,include,$(get_libdir)} /usr/share/man/{man1,man3}
	emake ROOT="${D}" install || die
}
