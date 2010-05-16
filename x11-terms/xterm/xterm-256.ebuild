# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/xterm/xterm-256.ebuild,v 1.1 2010/04/14 14:40:03 ssuominen Exp $

EAPI=2
inherit multilib eutils

DESCRIPTION="Terminal Emulator for X Windows"
HOMEPAGE="http://dickey.his.com/xterm/"
SRC_URI="ftp://invisible-island.net/${PN}/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="toolbar truetype unicode Xaw3d"

COMMON_DEPEND="x11-libs/libX11
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libxkbfile
	x11-libs/libXft
	x11-libs/libXaw
	x11-apps/xmessage
	unicode? ( x11-apps/luit )
	Xaw3d? ( x11-libs/Xaw3d )
	kernel_linux? ( sys-libs/libutempter )"
RDEPEND="${COMMON_DEPEND}
	media-fonts/font-misc-misc"
DEPEND="${COMMON_DEPEND}
	x11-proto/xproto"

pkg_setup() {
	DEFAULTS_DIR="${EPREFIX}"/usr/share/X11/app-defaults
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-248-interix.patch
}

src_configure() {
	# laymans fix, can't find another way, fd_mask & POSIX_C_SOURCE issue
	[[ ${CHOST} == *-darwin8* ]] && export ac_cv_header_X11_Xpoll_h=no

	econf \
		--libdir="${EPREFIX}"/etc \
		--x-libraries="${EROOT}usr/$(get_libdir)" \
		--disable-full-tgetent \
		--with-app-defaults=${DEFAULTS_DIR} \
		--disable-setuid \
		--disable-setgid \
		--with-utempter \
		--with-x \
		$(use_with Xaw3d) \
		--disable-imake \
		--enable-256-color \
		--enable-broken-osc \
		--enable-broken-st \
		$(use_enable truetype freetype) \
		--enable-i18n \
		--enable-load-vt-fonts \
		--enable-logging \
		$(use_enable toolbar) \
		$(use_enable unicode mini-luit) \
		$(use_enable unicode luit) \
		--enable-wide-chars \
		--enable-dabbrev \
		--enable-warnings
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README{,.i18n} ctlseqs.txt
	dohtml xterm.log.html

	# Fix permissions -- it grabs them from live system, and they can
	# be suid or sgid like they were in pre-unix98 pty or pre-utempter days,
	# respectively (#69510).
	# (info from Thomas Dickey) - Donnie Berkholz <spyderous@gentoo.org>
	fperms 0755 /usr/bin/xterm

	# restore the navy blue
	sed -i -e "s:blue2$:blue:" "${ED}"${DEFAULTS_DIR}/XTerm-color
}
