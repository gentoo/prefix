# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/xca/xca-0.7.0.ebuild,v 1.4 2009/11/08 20:20:03 nixnut Exp $

EAPI="2"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="A graphical user interface to OpenSSL, RSA public keys, certificates, signing requests and revokation lists"
HOMEPAGE="http://www.hohnstaedt.de/xca.html"
SRC_URI="mirror://sourceforge/xca/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

RDEPEND=">=dev-libs/openssl-0.9.8
	x11-libs/qt-gui:4"
DEPEND="${RDEPEND}
	doc? ( app-text/linuxdoc-tools )"

# Upstream:
# http://sourceforge.net/tracker/index.php?func=detail&aid=1800298&group_id=62274&atid=500028
#
# 1. Qt detection.
# 2. doc hacks.

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.6.4-build.patch \
		"${FILESDIR}"/${P}-gcc44.patch
	sed -e 's/$(LD) $(LDFLAGS)/$(LD) $(RAW_LDFLAGS)/' -i Makefile Rules.mak || die "sed failed"
}

src_configure() {
	local LINUXDOC
	use doc || LINUXDOC='touch $@ && true'

	QTDIR="${EPREFIX}"/usr \
		STRIP="true" \
		LINUXDOC="${LINUXDOC}" \
		CC="$(tc-getCXX)" \
		LD="$(tc-getLD)" \
		CFLAGS="${CXXFLAGS}" \
		prefix="${EPREFIX}"/usr \
		./configure || die	"configure failed"
}

src_compile() {
	emake RAW_LDFLAGS="$(raw-ldflags)" || die "emake failed"
}

src_install() {
	emake destdir="${D}" mandir="share/man" install || die "emake install failed"

	dodoc AUTHORS

	insinto /etc/xca
	doins misc/*.txt
}
