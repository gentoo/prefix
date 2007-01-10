# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/distcc/distcc-2.18.3-r10.ebuild,v 1.6 2007/01/05 09:14:13 flameeyes Exp $

EAPI="prefix"

# If you change this in any way please email lisa@gentoo.org and make an
# entry in the ChangeLog (this means you spanky :P). (2004-04-11) Lisa Seelye

inherit eutils flag-o-matic toolchain-funcs

PATCHLEVEL="2.18"

DESCRIPTION="a program to distribute compilation of C code across several machines on a network"
HOMEPAGE="http://distcc.samba.org/"
SRC_URI="http://distcc.samba.org/ftp/distcc/distcc-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="gnome gtk selinux ipv6"

DEPEND=">=sys-apps/portage-2.0.49-r6
	|| ( >=sys-devel/gcc-config-1.3.1 app-admin/eselect-compiler )
	userland_GNU? ( sys-apps/shadow )
	gnome? ( dev-util/pkgconfig )
	gtk? ( dev-util/pkgconfig )"
RDEPEND="
	gnome? (
		>=x11-libs/gtk+-2.0.0
		>=gnome-base/libgnome-2.0.0
		>=gnome-base/libgnomeui-2.0.0.0
		>=gnome-base/libglade-2.0.0
		x11-libs/pango
		>=gnome-base/gconf-2.0.0
	)
	gtk? (
		>=x11-libs/gtk+-2.0.0
		x11-libs/pango
	)
	selinux? ( sec-policy/selinux-distcc )"

src_unpack() {
	unpack ${A}
	cd ${S}

	# -Wl,--as-needed to close bug #128605
	epatch ${FILESDIR}/distcc-as-needed.patch

	# See bug #75420 for more multilib stuff
	epatch ${FILESDIR}/distcc-gentoo-multilib-r1.patch
	einfo "Please report to bug #75420 success or failure of this patch."

	# prefix awareness
	cp "${FILESDIR}"/distcc-config .
	epatch "${FILESDIR}"/distcc-config-prefix.patch
	eprefixify distcc-config
}

src_compile() {
	local myconf="--with-included-popt "
	#Here we use the built in parse-options package. saves a dependancy

	#not taking any chances here, guessing which takes precedence in the
	#configure script, so we'll just make the distinction here:
	#gnome takes precedence over gtk if both are specified (gnome pulls
	#in gtk anyways...)
	use gtk && ! use gnome && myconf="${myconf} --with-gtk"
	use gtk && use gnome && myconf="${myconf} --with-gnome"

	#More legacy stuff?
	[ `gcc-major-version` -eq 2 ] && filter-lfs-flags

	if use ipv6; then
		ewarn "To use IPV6 you must have IPV6 compiled into your kernel"
		ewarn "either via a module or compiled code"
		ewarn "You can recompile without ipv6 with: USE='-ipv6' emerge distcc"
		myconf=" ${myconf} --enable-rfc2553 "
		epause 5
	fi
	econf ${myconf} || die "econf ${myconf} failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D%/}" install

	insinto /usr/share/doc/${PN}
	doins "${S}/survey.txt"

	exeinto /usr/bin
	doexe "${S}/distcc-config"

	insinto /etc/conf.d
	newins "${FILESDIR}/${PATCHLEVEL}/conf" distccd

	exeinto /etc/init.d
	newexe "${FILESDIR}/${PATCHLEVEL}/init" distccd

	# create and keep the symlink dir
	dodir /usr/lib/distcc/bin
	keepdir /usr/lib/distcc/bin

	# create the distccd pid directory
	dodir /var/run/distccd
	keepdir /var/run/distccd

	if use gnome || use gtk; then
	  einfo "Renaming /usr/bin/distccmon-gnome to /usr/bin/distccmon-gui"
	  einfo "This is to have a little sensability in naming schemes between distccmon programs"
	  mv ${ED}/usr/bin/distccmon-gnome ${ED}/usr/bin/distccmon-gui
	  dosym /usr/bin/distccmon-gui /usr/bin/distccmon-gnome
	fi

}

pkg_preinst() {
	# non-/ installs don't require us to do anything here
	[ "${EROOT}" != "/" ] && return 0

	# stop daemon since script is being updated
	[ -n "$(pidof distccd)" -a -x /etc/init.d/distccd ] && \
		/etc/init.d/distccd stop
}

pkg_postinst() {
	#are we doing bootstrap with has no useradd?
	if [[ ${CHOST} != *-*-gnu && ${CHOST} != *-linux* ]] || [ -x /usr/sbin/useradd ]; then
	  enewuser distcc 240
	else
	  ewarn "You do not have useradd (bootstrap) from shadow so I didn't"
	  ewarn "install the distcc user.  Note that attempting to start the daemon"
	  ewarn "will fail. Please install shadow and re-emerge distcc."
	  ebeep 2
	fi

	# By now everyone should be using the right envfile

	if [ "${EROOT}" = "${EPREFIX}" ]; then
		einfo "Installing links to native compilers..."
		"${EPREFIX}"/usr/bin/distcc-config --install
	else
		# distcc-config can *almost* handle ROOT installs itself
		#  but for now, but user must finsh things off
		ewarn "*** Installation is not complete ***"
		ewarn "You must run the following as root:"
		ewarn "  /usr/bin/distcc-config --install"
		ewarn "after booting or chrooting into ${EROOT}"
	fi
	einfo "Setting permissions on ${EROOT}var/run/distccd"
	chown -R distcc:daemon ${EROOT}var/run/distccd
	echo ""

	einfo "Tips on using distcc with Gentoo can be found at"
	einfo "http://www.gentoo.org/doc/en/distcc.xml"
	echo ""
	einfo "To use the distccmon programs with Gentoo you should use this command:"
	einfo "      DISTCC_DIR=/var/tmp/portage/.distcc distccmon-text N"
	use gnome || use gtk && einfo "Or:   DISTCC_DIR=/var/tmp/portage/.distcc distccmon-gnome"

	ewarn "***SECURITY NOTICE***"
	ewarn "If you are upgrading distcc please make sure to run etc-update to"
	ewarn "update your /etc/conf.d/distccd and /etc/init.d/distccd files with"
	ewarn "added security precautions (the --listen and --allow directives)"
#	ebeep 5
}
