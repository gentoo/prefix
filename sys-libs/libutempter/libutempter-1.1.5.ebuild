# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libutempter/libutempter-1.1.5.ebuild,v 1.1 2007/02/28 15:47:43 seemant Exp $

EAPI="prefix"

inherit eutils flag-o-matic versionator toolchain-funcs

DESCRIPTION="Library that allows non-privileged apps to write utmp (login) info, which need root access"
HOMEPAGE="http://altlinux.org/index.php?module=sisyphus&package=libutempter"
SRC_URI="ftp://ftp.altlinux.org/pub/people/ldv/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE=""

DEPEND="!virtual/utempter"
RDEPEND="!virtual/utempter"

PROVIDE="virtual/utempter"

pkg_setup() {
	enewgroup utmp 406
}

src_compile() {
	use elibc_FreeBSD && append-flags -lutil
	emake \
		CC="$(tc-getCC)" \
		RPM_OPT_FLAGS="${CFLAGS}" \
		libdir="${EPREFIX}"/usr/$(get_libdir) \
		libexecdir="${EPREFIX}"/usr/$(get_libdir)/misc || die
}

src_install() {
	make \
		DESTDIR="${D}" \
		libdir="${EPREFIX}"/usr/$(get_libdir) \
		libexecdir="${EPREFIX}"/usr/$(get_libdir)/misc \
		includedir="${EPREFIX}"/usr/include \
		install || die

	use prefix && fowners root:utmp /usr/$(get_libdir)/misc/utempter/utempter
	fperms 2755 /usr/$(get_libdir)/misc/utempter/utempter
	dodir /usr/sbin
	dosym ../$(get_libdir)/misc/utempter/utempter /usr/sbin/utempter
	dodoc README
}


pkg_postinst() {
	if [ -f "${EROOT}/var/log/wtmp" ]
	then
		chown root:utmp "${EROOT}/var/log/wtmp"
		chmod 664 "${EROOT}/var/log/wtmp"
	fi

	if [ -f "${EROOT}/var/run/utmp" ]
	then
		chown root:utmp "${EROOT}/var/run/utmp"
		chmod 664 "${EROOT}/var/run/utmp"
	fi
}
