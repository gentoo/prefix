# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/screen/screen-4.0.3.ebuild,v 1.7 2006/10/26 19:59:08 corsair Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs pam autotools

DESCRIPTION="Screen is a full-screen window manager that multiplexes a physical terminal between several processes"
HOMEPAGE="http://www.gnu.org/software/screen/"
SRC_URI="ftp://ftp.uni-erlangen.de/pub/utilities/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="debug nethack pam selinux multiuser"

RDEPEND=">=sys-libs/ncurses-5.2
	pam? ( virtual/pam )
	selinux? (
		sec-policy/selinux-screen
		>=sec-policy/selinux-base-policy-20050821
	)"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.58"

pkg_setup() {
	# Make sure utmp group exists, as it's used later on.
	enewgroup utmp 406
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Bug 34599: integer overflow in 4.0.1
	# (Nov 29 2003 -solar)
	epatch "${FILESDIR}"/screen-4.0.1-int-overflow-fix.patch

	# Bug 31070: configure problem which affects alpha
	# (13 Jan 2004 agriffis)
	epatch "${FILESDIR}"/screen-4.0.1-vsprintf.patch

	# uclibc doesnt have sys/stropts.h
	if ! (echo '#include <sys/stropts.h>' | $(tc-getCC) -E - &>/dev/null) ; then
		epatch "${FILESDIR}"/4.0.2-no-pty.patch
	fi

	# Don't use utempter even if it is found on the system
	epatch "${FILESDIR}"/4.0.2-no-utempter.patch

	# Don't link against libelf even if it is found on the system
	epatch "${FILESDIR}"/4.0.2-no-libelf.patch

	# Patch for time function on 64bit systems
	epatch "${FILESDIR}"/4.0.2-64bit-time.patch

	# Patch that makes %u work for windowlist -b formats
	epatch "${FILESDIR}"/4.0.2-windowlist-multiuser-fix.patch

	# Open tty in non-blocking mode
	epatch "${FILESDIR}"/4.0.2-nonblock.patch

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
	epatch "${FILESDIR}"/${P}-setenv_autoconf.patch

	# configure as delivered with screen is made with autoconf-2.5
	WANT_AUTOCONF=2.5 eautoconf
}

src_compile() {
	addpredict "$(tty)"
	addpredict "${SSH_TTY}"

	append-flags "-DMAXWIN=${MAX_SCREEN_WINDOWS:-100}"
	append-ldflags $(bindnow-flags)
	use userland_Solaris && append-ldflags -lsocket -lnsl

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

	# Second try to fix bug 12683, this time without changing term.h
	# The last try seemed to break screen at run-time.
	# (16 Jan 2003 agriffis)
	LC_ALL=POSIX make term.h || die "Failed making term.h"

	emake || die "emake failed"
}

src_install() {
	dobin screen || die "dobin failed"
	keepdir /var/run/screen || die "keepdir failed"

	if use multiuser
	then
		fperms 4755 /usr/bin/screen || die "fperms failed"
	else
		fowners root:utmp /{usr/bin,var/run}/screen \
			|| die "fowners failed, use multiuser USE-flag instead"
		fperms 2755 /usr/bin/screen || die "fperms failed"
	fi

	insinto /usr/share/terminfo
	doins terminfo/screencap || die "doins failed"
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
	if use multiuser
	then
		chown root:0 "${EROOT}"/var/run/screen
		chmod 0755 "${EROOT}"/var/run/screen
	else
		chown root:utmp "${EROOT}"/var/run/screen
		chmod 0775 "${EROOT}"/var/run/screen
	fi

	einfo "Some dangerous key bindings have been removed or changed to more safe values."
	einfo "We enable some xterm hacks in our default screenrc, which might break some"
	einfo "applications. Please check /etc/screenrc for information on these changes."
}
