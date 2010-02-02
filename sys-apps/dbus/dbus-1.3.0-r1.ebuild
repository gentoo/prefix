# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.3.0-r1.ebuild,v 1.3 2009/11/23 21:27:56 eva Exp $

EAPI="2"

inherit autotools eutils multilib flag-o-matic

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc selinux test X"

RDEPEND="X? ( x11-libs/libXt x11-libs/libX11 )
	selinux? ( sys-libs/libselinux
				sec-policy/selinux-dbus )
	>=dev-libs/expat-1.95.8
	!<sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		app-doc/doxygen
		app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2 )"

# out of sources build directory
BD=${WORKDIR}/${P}-build
# out of sources build dir for make check
TBD=${WORKDIR}/${P}-tests-build

src_prepare() {
	# Remove CFLAGS that is not supported by all gcc, bug #274456
	sed 's/-Wno-pointer-sign//g' -i configure.in configure || die "sed failed"

	# Tests were restricted because of this
	sed -e 's/.*bus_dispatch_test.*/printf ("Disabled due to excess noise\\n");/' \
		-e '/"dispatch"/d' -i "${S}/bus/test-main.c"

	epatch "${FILESDIR}"/${PN}-1.2.3-darwin.patch
	epatch "${FILESDIR}"/${P}-unix-fd-check.patch # from upstream
	epatch "${FILESDIR}"/${PN}-1.2.1-interix.patch
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${P}-interix5.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.2.1-interix3.patch

	# don't apply this unconditionally, as it will doom dbus on all other
	# platforms (root <-> Administrator - argl).
	if [[ ${CHOST} == *-interix* ]]; then
		cp "${FILESDIR}"/${P}-interix-all.patch "${T}"/itx.patch

		# replace hardcoded values to enable portage pseudo root beeing
		# system bus owner.
		sed -i \
			-e "s,+Administrators,$(id -gn),g" \
			-e "s,Administrator,$(id -un),g" \
			-e "s,197108,$(id -u),g" \
				"${T}"/itx.patch

		epatch "${T}"/itx.patch
	fi

	epatch "${FILESDIR}"/${P}-asneeded.patch
	epatch "${FILESDIR}"/${P}-no-cloexec.patch
	# required for asneeded patch but also for bug 263909, cross-compile so
	# don't remove eautoreconf
	# also required for interix patches
	eautoreconf
}

src_configure() {
	local my_conf
	local syssocket="${EPREFIX}"/var/run/dbus/system_bus_socket
	local socketdir="${EPREFIX}"/tmp
	local dbususer=messagebus

	if [[ ${CHOST} == *-interix* ]]; then
		# incorrect detection of some functions, and some are there but badly
		# broken, so don't use them if possible.
		export ac_cv_func_poll=no
		export ac_cv_func_getgrouplist=no

		# take the current portage running user, as this is our local "root"
		dbususer=$(id -un)
	fi

	if [[ ${CHOST} == *-interix5* ]]; then
		# interix 5.2 socket paths may not be longer than 14
		# chars including the zero. (bug alarm...)
		syssocket="/tmp/dbus_ss"
		socketdir="/tmp"

		myconf="${myconf} --with-test-socket-dir=/tmp"
	fi

	if [[ ${CHOST} == *-solaris* ]] ; then
		# struct msghdr doesn't include msg_controllen if _XPG4_2 isn't
		# defined (or the kernel view).  To enable it, _XOPEN_SOURCE
		# must be set to 500.  However, then we loose *DIR->dd_fd, so we
		# just do an ugly hack and enable the private macro.
		append-flags -D_XPG4_2
	fi

	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	my_conf="$(use_with X x)
		$(use_enable debug verbose-mode)
		$(use_enable debug asserts)
		$(use_enable kernel_linux inotify)
		$(use_enable kernel_FreeBSD kqueue)
		$(use_enable kernel_Darwin kqueue)
		$(use_enable selinux)
		$(use_enable selinux libaudit)
		--with-xml=expat
		--with-system-pid-file="${EPREFIX}"/var/run/dbus.pid
		--with-system-socket=${syssocket}
		--with-session-socket-dir=${socketdir}
		--with-dbus-user="${dbususer}"
		--localstatedir="${EPREFIX}"/var"

	mkdir "${BD}"
	cd "${BD}"
	einfo "Running configure in ${BD}"
	ECONF_SOURCE="${S}" econf ${my_conf} \
		$(use_enable doc doxygen-docs) \
		$(use_enable doc xml-docs)

	if use test; then
		mkdir "${TBD}"
		cd "${TBD}"
		einfo "Running configure in ${TBD}"
		ECONF_SOURCE="${S}" econf \
			${my_conf} \
			$(use_enable test checks) \
			$(use_enable test tests) \
			$(use_enable test asserts)
	fi
}

src_compile() {
	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	cd "${BD}"
	einfo "Running make in ${BD}"
	emake || die "make failed"

	if use doc; then
		einfo "Building API documentation..."
		doxygen || die "doxygen failed"
	fi

	if use test; then
		cd "${TBD}"
		einfo "Running make in ${TBD}"
		emake || die "make failed"
	fi
}

src_test() {
	cd "${TBD}"
	DBUS_VERBOSE=1 make check || die "make check failed"
}

src_install() {
	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus

	if use X ; then
		# dbus X session script (#77504)
		# turns out to only work for GDM. has been merged into other desktop
		# (kdm and such scripts)
		exeinto /etc/X11/xinit/xinitrc.d/
		doexe "${FILESDIR}"/30-dbus || die "doexe failed"
	fi

	# needs to exist for the system socket
	keepdir /var/run/dbus
	# needs to exist for machine id
	keepdir /var/lib/dbus
	# needs to exist for dbus sessions to launch

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO || die "dodoc failed"

	cd "${BD}"
	# FIXME: split dtd's in dbus-dtd ebuild
	emake DESTDIR="${D}" install || die "make install failed"
	if use doc; then
		dohtml doc/*.html doc/api/html/* || die "dohtml failed"
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
	ewarn "You must restart D-Bus \`/etc/init.d/dbus restart\` to run"
	ewarn "the new version of the daemon."

	if has_version "x11-base/xorg-server[hal]"; then
		elog
		ewarn "You are currently running X with the hal useflag enabled"
		ewarn "restarting the dbus service WILL restart X as well"
		ebeep 5
	fi

	# Ensure unique id is generated
	dbus-uuidgen --ensure="${EROOT}"/var/lib/dbus/machine-id
}
