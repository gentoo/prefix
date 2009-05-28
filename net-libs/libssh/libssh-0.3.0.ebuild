# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh/libssh-0.3.0.ebuild,v 1.1 2009/05/25 21:00:09 pva Exp $

# Maintainer: check IUSE-defaults at DefineOptions.cmake
EAPI="2"
inherit eutils cmake-utils

DESCRIPTION="Access a working SSH implementation by means of a library"
HOMEPAGE="http://www.libssh.org/"
SRC_URI="http://www.libssh.org/files/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="gcrypt examples +sftp ssh1 server zlib"

DEPEND="zlib? ( >=sys-libs/zlib-1.2 )
	!gcrypt? ( >=dev-libs/openssl-0.9.8 )
	gcrypt? ( >=dev-libs/libgcrypt-1.4 )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${P}-automagic-crypt.patch"
}

src_configure() {
	local mycmakeargs="$(cmake-utils_use_with gcrypt GCRYPT
	cmake-utils_use_with zlib LIBZ
	cmake-utils_use_with sftp SFTP
	cmake-utils_use_with ssh1 SSH1
	cmake-utils_use_with server SERVER)"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc AUTHORS README ChangeLog || die
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins sample.c samplesshd.c
	fi
}
