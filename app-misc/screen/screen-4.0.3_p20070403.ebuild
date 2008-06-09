# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/screen/screen-4.0.3_p20070403.ebuild,v 1.4 2008/06/07 19:05:56 swegener Exp $

EAPI="prefix"

WANT_AUTOCONF="2.5"

inherit eutils flag-o-matic toolchain-funcs pam autotools

DESCRIPTION="Screen is a full-screen window manager that multiplexes a physical terminal between several processes"
HOMEPAGE="http://www.gnu.org/software/screen/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="debug nethack pam selinux multiuser"

RDEPEND=">=sys-libs/ncurses-5.2
	pam? ( virtual/pam )
	selinux? (
		sec-policy/selinux-screen
		>=sec-policy/selinux-base-policy-20050821
	)"
DEPEND="${RDEPEND}"

pkg_setup() {
	# Make sure utmp group exists, as it's used later on.
	enewgroup utmp 406
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# uclibc doesnt have sys/stropts.h
	if ! (echo '#include <sys/stropts.h>' | $(tc-getCC) -E - &>/dev/null) ; then
		epatch "${FILESDIR}"/4.0.2-no-pty.patch
	fi

	# Fix some keybindings
	epatch "${FILESDIR}"/${P}-map.patch

	# Don't use utempter even if it is found on the system
	epatch "${FILESDIR}"/4.0.2-no-utempter.patch

	# Don't link against libelf even if it is found on the system
	epatch "${FILESDIR}"/4.0.2-no-libelf.patch

	# compability for sys-devel/autoconf-2.62
	epatch "${FILESDIR}"/screen-4.0.3-config.h-autoconf-2.62.patch

	# Allow for more rendition (color/attribute) changes in status bars
	sed -i \
		-e "s:#define MAX_WINMSG_REND 16:#define MAX_WINMSG_REND 64:" \
		screen.c \
		|| die "sed screen.c failed"

	# Fix manpage.
	sed -i \
		-e "s:/usr/local/etc/screenrc:${EPREFIX}/etc/screenrc:g" \
		-e "s:/usr/local/screens:${EPREFIX}/var/run/screen:g" \
		-e "s:/local/etc/screenrc:${EPREFIX}/etc/screenrc:g" \
		-e "s:/etc/utmp:${EPREFIX}/var/run/utmp:g" \
		-e "s:/local/screens/S-:${EPREFIX}/var/run/screen/S-:g" \
		doc/screen.1 \
		|| die "sed doc/screen.1 failed"

	# proper setenv detection for Solaris
	epatch "${FILESDIR}"/${PN}-4.0.3-setenv_autoconf.patch

	eautoconf
}

src_compile() {
	append-flags "-DMAXWIN=${MAX_SCREEN_WINDOWS:-100}"

	[[ ${CHOST} == *-solaris* ]] && append-ldflags -lsocket -lnsl

	use nethack || append-flags "-DNONETHACK"
	use debug && append-flags "-DDEBUG"

	econf \
		--with-socket-dir="${EPREFIX}"/var/run/screen \
		--with-sys-screenrc="${EPREFIX}"/etc/screenrc \
		--with-pty-mode=0620 \
		--with-pty-group=5 \
		--enable-rxvt_osc \
		--enable-telnet \
		--enable-colors256 \
		$(use_enable pam) \
		|| die "econf failed"

	LC_ALL=POSIX make term.h || die "Failed making term.h"

	emake || die "emake failed"
}

src_install() {
	dobin screen || die "dobin failed"
	keepdir /var/run/screen || die "keepdir failed"

	if use multiuser || use prefix
	then
		fperms 4755 /usr/bin/screen || die "fperms failed"
	else
		fowners root:utmp /{usr/bin,var/run}/screen \
			|| die "fowners failed, use multiuser USE-flag instead"
		fperms 2755 /usr/bin/screen || die "fperms failed"
	fi

	insinto /usr/share/screen
	doins terminfo/{screencap,screeninfo.src} || die "doins failed"
	insinto /usr/share/screen/utf8encodings
	doins utf8encodings/?? || die "doins failed"
	insinto /etc
	doins "${FILESDIR}"/screenrc || die "doins failed"

	pamd_mimic_system screen auth || die "pamd_mimic_system failed"

	dodoc \
		README ChangeLog INSTALL TODO NEWS* patchlevel.h \
		doc/{FAQ,README.DOTSCREEN,fdpat.ps,window_to_display.ps} \
		|| die "dodoc failed"

	doman doc/screen.1 || die "doman failed"
	doinfo doc/screen.info* || die "doinfo failed"
}

pkg_postinst() {
	if use multiuser || use prefix
	then
		use prefix || chown root:0 "${EROOT}"/var/run/screen
		chmod 0755 "${EROOT}"/var/run/screen
	else
		chown root:utmp "${EROOT}"/var/run/screen
		chmod 0775 "${EROOT}"/var/run/screen
	fi

	elog "Some dangerous key bindings have been removed or changed to more safe values."
	elog "We enable some xterm hacks in our default screenrc, which might break some"
	elog "applications. Please check /etc/screenrc for information on these changes."

	ewarn "Please terminate your running screen sessions, as screen now uses sockets"
	ewarn "instead of fifos and the new version can't attach to the old sessions."
}
