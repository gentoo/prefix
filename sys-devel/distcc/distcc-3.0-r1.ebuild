# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/distcc/distcc-3.0-r1.ebuild,v 1.1 2008/10/19 14:45:22 matsuu Exp $

EAPI="prefix"

# If you change this in any way please email lisa@gentoo.org and make an
# entry in the ChangeLog (this means you spanky :P). (2004-04-11) Lisa Seelye

inherit eutils flag-o-matic toolchain-funcs fdo-mime

DESCRIPTION="a program to distribute compilation of C code across several machines on a network"
HOMEPAGE="http://distcc.org/"
SRC_URI="http://distcc.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="avahi gnome gtk ipv6 selinux"

RESTRICT="test"

RDEPEND=">=dev-lang/python-2.4
	dev-libs/popt
	avahi? ( >=net-dns/avahi-0.6 )
	gnome? (
		>=gnome-base/libgnome-2
		>=gnome-base/libgnomeui-2
		>=x11-libs/gtk+-2
		x11-libs/pango
	)
	gtk? (
		>=x11-libs/gtk+-2
	)"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
RDEPEND="${RDEPEND}
	!net-misc/pump
	>=sys-devel/gcc-config-1.3.1
	selinux? ( sec-policy/selinux-distcc )"

pkg_setup() {
	if use ipv6; then
		ewarn "To use IPv6 you must have IPv6 compiled into your kernel"
		ewarn "either via a module or compiled code"
		ewarn "You can recompile without ipv6 with: USE='-ipv6' emerge distcc"
		epause 5
	fi

	enewuser distcc 240 -1 -1 daemon
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-gentoo.patch"
	epatch "${FILESDIR}/${P}-svn617.patch"

	# prefix awareness
	cp "${FILESDIR}"/distcc-config .
	epatch "${FILESDIR}"/distcc-config-prefix.patch
	eprefixify distcc-config
}

src_compile() {
	# More legacy stuff?
	[ "$(gcc-major-version)" = "2" ] && filter-lfs-flags

	# -O? is required
	[ "${CFLAGS/-O}" = "${CFLAGS}" ] && CFLAGS="${CFLAGS} -O2"

	econf \
		$(use_with avahi) \
		$(use_with gtk) \
		$(use_with gnome) \
		$(use_enable ipv6 rfc2553) \
		--with-docdir="${EPREFIX}/usr/share/doc/${PF}" || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die

	dobin "${FILESDIR}/${PV}/distcc-config"

	newinitd "${FILESDIR}/${PV}/init" distccd
	cp "${FILESDIR}/${PV}/conf" "${T}/conf"
	if use avahi; then
		(
			echo
			echo '# Enable zeroconf support in distccd'
			echo 'DISTCCD_OPTS="${DISTCCD_OPTS} --zeroconf"'
		) >> "${T}/conf"
	fi
	newconfd "${T}/conf" distccd

	# create the masquerade directory
	local DCCC_PATH="/usr/$(get_libdir)/distcc/bin/"
	dodir "${DCCC_PATH}"
	for f in cc c++ gcc g++; do
		dosym /usr/bin/distcc "${DCCC_PATH}${f}"
		if [ "${f}" != "cc" ]; then
			dosym /usr/bin/distcc "${DCCC_PATH}${CTARGET:-${CHOST}}-${f}"
		fi
	done

	# create the distccd pid directory
	keepdir /var/run/distccd
	fowners distcc:daemon /var/run/distccd

	if use gnome || use gtk; then
	  einfo "Renaming /usr/bin/distccmon-gnome to /usr/bin/distccmon-gui"
	  einfo "This is to have a little sensability in naming schemes between distccmon programs"
	  mv "${ED}/usr/bin/distccmon-gnome" "${ED}/usr/bin/distccmon-gui" || die
	  dosym distccmon-gui /usr/bin/distccmon-gnome
	fi

	rm -rf "${ED}/etc/default"
	rm -f "${ED}/etc/distcc/clients.allow"
	rm -f "${ED}/etc/distcc/commands.allow.sh"
	prepalldocs
}

pkg_postinst() {
	use gnome && fdo-mime_desktop_database_update

	# By now everyone should be using the right envfile
	if [ "${ROOT}" = "/" ]; then
		einfo "Installing links to native compilers..."
		"${EPREFIX}"/usr/bin/distcc-config --install
	else
		# distcc-config can *almost* handle ROOT installs itself
		#  but for now, but user must finsh things off
		elog "*** Installation is not complete ***"
		elog "You must run the following as root:"
		elog "  /usr/bin/distcc-config --install"
		elog "after booting or chrooting into ${EROOT}"
	fi

	elog
	elog "Tips on using distcc with Gentoo can be found at"
	elog "http://www.gentoo.org/doc/en/distcc.xml"
	elog
	elog "To use the distccmon programs with Gentoo you should use this command:"
	elog "# DISTCC_DIR=\"${DISTCC_DIR}\" distccmon-text 5"

	if use gnome || use gtk; then
		elog "Or:"
		elog "# DISTCC_DIR=\"${DISTCC_DIR}\" distccmon-gnome"
	fi

	elog
	elog "***SECURITY NOTICE***"
	elog "If you are upgrading distcc please make sure to run etc-update to"
	elog "update your /etc/conf.d/distccd and /etc/init.d/distccd files with"
	elog "added security precautions (the --listen and --allow directives)"
	elog
}

pkg_postrm() {
	use gnome && fdo-mime_desktop_database_update
}
