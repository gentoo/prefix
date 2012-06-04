# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libutempter/libutempter-1.1.5-r1.ebuild,v 1.1 2012/05/24 05:37:41 vapier Exp $

EAPI="4"

inherit user multilib flag-o-matic

DESCRIPTION="Library that allows non-privileged apps to write utmp (login) info, which need root access"
HOMEPAGE="http://altlinux.org/index.php?module=sisyphus&package=libutempter"
SRC_URI="ftp://ftp.altlinux.org/pub/people/ldv/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="static-libs elibc_FreeBSD"

RDEPEND="!sys-apps/utempter"

pkg_setup() {
	enewgroup utmp 406
}

src_prepare() {
	local args=(
		-e "/^libdir /s:/usr/lib:${EPREFIX}/usr/$(get_libdir):"
		-e '/^libexecdir /s:=.*:= $(libdir)/misc:'
		-e '/^CFLAGS = $(RPM_OPT_FLAGS)/d'
		-e 's:,-stats::'
		-e "/^includedir /s:/usr/include:${EPREFIX}/usr/include:"
	)
	use static-libs || args+=(
			-e '/^STATICLIB/d'
			-e '/INSTALL.*STATICLIB/d'
		)
	sed -i "${args[@]}" Makefile || die
}

src_configure() {
	use elibc_FreeBSD && append-libs -lutil
	tc-export CC
}

src_install() {
	default

	use prefix && fowners root:utmp /usr/$(get_libdir)/misc/utempter/utempter
	fperms 2755 /usr/$(get_libdir)/misc/utempter/utempter
	dodir /usr/sbin
	dosym ../$(get_libdir)/misc/utempter/utempter /usr/sbin/utempter
}

pkg_postinst() {
	if [ -f "${EROOT}/var/log/wtmp" ] ; then
		chown root:utmp "${EROOT}/var/log/wtmp"
		chmod 664 "${EROOT}/var/log/wtmp"
	fi

	if [ -f "${EROOT}/var/run/utmp" ] ; then
		chown root:utmp "${EROOT}/var/run/utmp"
		chmod 664 "${EROOT}/var/run/utmp"
	fi
}
