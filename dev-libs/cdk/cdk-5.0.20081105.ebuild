# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/cdk/cdk-5.0.20081105.ebuild,v 1.2 2009/02/03 04:23:16 mr_bones_ Exp $

inherit eutils versionator toolchain-funcs

MY_P="${PN}-$(replace_version_separator 2 -)"
DESCRIPTION="A library of curses widgets"
HOMEPAGE="http://dickey.his.com/cdk/cdk.html"
SRC_URI="ftp://invisible-island.net/cdk/${MY_P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="examples"

DEPEND=">=sys-libs/ncurses-5.2"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-ldflags.patch
}

src_compile() {
	tc-export CC
	econf \
		--with-ncurses --with-libtool \
		|| die

	emake || die
}

src_install() {
	emake -j1 \
		DESTDIR="${D}" \
		DOCUMENT_DIR="${ED}/usr/share/doc/${MY_P}" install \
		|| die

	if $(use examples); then
		for x in include c++ demos examples cli cli/utils cli/samples; do
			docinto $x
			find $x -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 dodoc
		done
	fi
}
