# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/pam_mktemp/pam_mktemp-1.0.3.ebuild,v 1.16 2008/10/27 05:59:54 vapier Exp $

inherit toolchain-funcs pam

DESCRIPTION="Create per-user private temporary directories during login"
HOMEPAGE="http://www.openwall.com/pam/"
SRC_URI="http://www.openwall.com/pam/modules/${PN}/${P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND="virtual/pam"
RDEPEND="${DEPEND}"

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -fPIC" \
		LDFLAGS="${LDFLAGS} --shared -Wl,--version-script,\$(MAP)" \
		|| die "emake failed"
}

src_install() {
	dopammod pam_mktemp.so
	dodoc README
}

pkg_postinst() {
	elog "To enable pam_mktemp put something like"
	elog
	elog "session    optional    pam_mktemp.so"
	elog
	elog "into /etc/pam.d/system-auth!"
}
