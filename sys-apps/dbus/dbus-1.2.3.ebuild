# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.2.3.ebuild,v 1.4 2008/12/07 10:15:57 vapier Exp $

inherit eutils multilib flag-o-matic

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="debug doc selinux X"

RDEPEND="X? ( x11-libs/libXt x11-libs/libX11 )
	selinux? ( sys-libs/libselinux
				sec-policy/selinux-dbus )
	>=dev-libs/expat-1.95.8
	!<sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (	app-doc/doxygen
		app-text/xmlto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.3-darwin.patch

	epatch "${FILESDIR}"/${PN}-1.2.1-interix.patch
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${PN}-1.2.1-interix5.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.2.1-interix3.patch

	eautoreconf
}

src_compile() {
	local syssocket="${EPREFIX}"/var/run/dbus/system_bus_socket
	local socketdir="${EPREFIX}"/tmp

	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_poll=no
	fi

	if [[ ${CHOST} == *-interix5* ]]; then
		# interix 5.2 socket paths may not be longer than 14
		# chars including the zero. (bug alarm...)
		syssocket="/tmp/dbus_ss"
		socketdir="/tmp"

		myconf="${myconf} --with-test-socket-dir=/tmp"
	fi

	if [[ ${CHOST} != *-interix* ]]; then
		# so we can get backtraces from apps
		append-flags -rdynamic
	fi

	local myconf=""

	hasq test ${FEATURES} && myconf="${myconf} --enable-tests=yes"
	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	econf \
		$(use_with X x) \
		$(use_enable kernel_linux inotify) \
		$(use_enable kernel_FreeBSD kqueue) \
		$(use_enable selinux) \
		$(use_enable selinux libaudit)	\
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		--with-xml=expat \
		--with-system-pid-file="${EPREFIX}"/var/run/dbus.pid \
		--with-system-socket="${syssocket}" \
		--with-session-socket-dir="${socketdir}" \
		--with-dbus-user=messagebus \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	emake || die "make failed"
}

src_test() {
	DBUS_VERBOSE=1 make check || die "make check failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus

	# dbus X session script (#77504)
	# turns out to only work for GDM. has been merged into other desktop
	# (kdm and such scripts)
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}"/30-dbus

	# needs to exist for the system socket
	keepdir /var/run/dbus
	# needs to exist for machine id
	keepdir /var/lib/dbus
	# needs to exist for dbus sessions to launch

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO
	if use doc; then
		dohtml doc/*html
	fi
}

pkg_preinst() {
	enewgroup messagebus
	enewuser messagebus -1 "-1" -1 messagebus
}

pkg_postinst() {
	elog "To start the D-Bus system-wide messagebus by default"
	elog "you should add it to the default runlevel :"
	elog "\`rc-update add dbus default\`"
	elog
	elog "Some applications require a session bus in addition to the system"
	elog "bus. Please see \`man dbus-launch\` for more information."
	elog
	elog
	ewarn "You MUST run 'revdep-rebuild' after emerging this package"
	elog
	ewarn "If you are currently running X with the hal useflag enabled"
	ewarn "restarting the dbus service WILL restart X as well"
	ebeep 5
	elog
	ewarn "You must restart D-Bus \`/etc/init.d/dbus restart\` to run"
	ewarn "the new version of the daemon. For many people, this means"
	ewarn "exiting X as well."

}
