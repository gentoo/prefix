# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/xca/xca-0.6.4.ebuild,v 1.7 2009/04/20 20:15:51 maekke Exp $

EAPI=1
inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="A graphical user interface to OpenSSL, RSA public keys, certificates, signing requests and revokation lists"
HOMEPAGE="http://www.hohnstaedt.de/xca.html"
SRC_URI="mirror://sourceforge/xca/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

RDEPEND=">=dev-libs/openssl-0.9.8
	|| ( x11-libs/qt-gui:4 =x11-libs/qt-4.3* )"
DEPEND="${RDEPEND}
	doc? ( app-text/linuxdoc-tools )"

# Upstream:
# http://sourceforge.net/tracker/index.php?func=detail&aid=1800298&group_id=62274&atid=500028
#
# 1. Qt detection.
# 2. doc hacks.

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-build.patch"
	epatch "${FILESDIR}/${P}-openssl.patch"
	epatch "${FILESDIR}/${P}-darwin.patch"
}

src_compile() {
	local LINUXDOC
	use doc || LINUXDOC='touch $@ && true'

	QTDIR="${EPREFIX}"/usr \
		STRIP="true" \
		LINUXDOC="${LINUXDOC}" \
		CC="$(tc-getCXX)" \
		LD="$(tc-getLD)" \
		LDFLAGS="$(raw-ldflags)" \
		prefix="${EPREFIX}"/usr \
		./configure || die	"configure failed"
	emake || die "emake failed"
}

src_install() {
	emake destdir="${D}" mandir="share/man" install || die "install failed"

	dodoc AUTHORS

	insinto /etc/xca
	doins misc/*.txt
}
