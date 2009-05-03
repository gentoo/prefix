# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/pinentry/pinentry-0.7.5-r1.ebuild,v 1.2 2009/05/02 20:33:05 swegener Exp $

EAPI=1

inherit qt3 multilib eutils flag-o-matic

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol"
HOMEPAGE="http://www.gnupg.org/aegypten/"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="gtk ncurses qt3 caps static"

DEPEND="static? ( sys-libs/ncurses )
	!static? (
		gtk? ( x11-libs/gtk+:2 )
		ncurses? ( sys-libs/ncurses )
		qt3? ( x11-libs/qt:3 )
		!gtk? ( !qt3? ( !ncurses? ( sys-libs/ncurses ) ) )
	)
	caps? ( sys-libs/libcap )"

RDEPEND="${DEPEND}"

pkg_setup() {
	use static && append-ldflags -static

	if use static && ( use gtk || use qt3 )
	then
		ewarn
		ewarn "The static USE flag is only supported with the ncurses USE flags, disabling the gtk and qt3 USE flags."
		ewarn
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-grab.patch"
	epatch "${FILESDIR}/${PN}-gmem.patch"
}

src_compile() {
	local myconf=""

	if ! ( use qt3 || use gtk || use ncurses )
	then
		myconf="--enable-pinentry-curses --enable-fallback-curses"
	elif use static
	then
		myconf="--enable-pinentry-curses --enable-fallback-curses --disable-pinentry-gtk2 --disable-pinentry-qt"
	fi

	# Issues finding qt on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"

	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		$(use_enable gtk pinentry-gtk2) \
		$(use_enable qt3 pinentry-qt) \
		$(use_enable ncurses pinentry-curses) \
		$(use_enable ncurses fallback-curses) \
		$(use_with caps libcap) \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO || die "dodoc failed"
}

pkg_postinst() {
	elog "We no longer install pinentry-curses and pinentry-qt SUID root by default."
	elog "Linux kernels >=2.6.9 support memory locking for unprivileged processes."
	elog "The soft resource limit for memory locking specifies the limit an"
	elog "unprivileged process may lock into memory. You can also use POSIX"
	elog "capabilities to allow pinentry to lock memory. To do so activate the caps"
	elog "USE flag and add the CAP_IPC_LOCK capability to the permitted set of"
	elog "your users."
}
