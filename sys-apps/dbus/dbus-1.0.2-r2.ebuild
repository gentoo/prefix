# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.0.2-r2.ebuild,v 1.13 2007/06/05 14:59:09 cardoe Exp $

EAPI="prefix"

inherit eutils multilib autotools flag-o-matic

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
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

	# fix dnotify issue with not detecting created files
	epatch "${FILESDIR}"/${PN}-1.0.1-fixfilecreation.patch
}

src_compile() {
	# so we can get backtraces from apps
	append-flags -rdynamic

	local myconf=""

	hasq test ${FEATURES} && myconf="${myconf} --enable-tests=yes"

	econf \
		$(use_with X x) \
		$(use_enable kernel_linux dnotify) \
		$(use_enable kernel_FreeBSD kqueue) \
		$(use_enable selinux) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		--with-xml=expat \
		--with-system-pid-file=${EPREFIX}/var/run/dbus.pid \
		--with-system-socket=${EPREFIX}/var/run/dbus/system_bus_socket \
		--with-session-socket-dir=${EPREFIX}/tmp \
		--with-dbus-user=messagebus \
		--localstatedir=${EPREFIX}/var \
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
	make DESTDIR="${D}" install || die "make install failed"

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

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO
	if use doc; then
		dohtml doc/*html
	fi
}

pkg_preinst() {
	enewgroup messagebus || die "Problem adding messagebus group"
	enewuser messagebus -1 "-1" -1 messagebus || die "Problem adding messagebus user"
}

pkg_postinst() {
	# ensure we create the machine uuid here for people that don't use the
	# system bus so it would never get created otherwise
	if [[ ${ROOT} == "/" ]] ; then
		"${EPREFIX}"/usr/bin/dbus-uuidgen --ensure
	fi

	elog "To start the D-Bus system-wide messagebus by default"
	elog "you should add it to the default runlevel :"
	elog "\`rc-update add dbus default\`"
	elog
	elog "Somme applications require a session bus in addition to the system"
	elog "bus. Please see \`man dbus-launch\` for more information."
	elog
	ewarn
	ewarn "You MUST run 'revdep-rebuild' after emerging this package"
	ewarn
}
