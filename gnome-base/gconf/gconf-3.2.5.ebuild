# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gconf/gconf-3.2.5.ebuild,v 1.4 2012/05/22 08:20:39 jlec Exp $

EAPI="4"
GCONF_DEBUG="yes"
GNOME_ORG_MODULE="GConf"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2

DESCRIPTION="Gnome Configuration System and Daemon"
HOMEPAGE="http://projects.gnome.org/gconf/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc +introspection ldap orbit policykit"

RDEPEND=">=dev-libs/glib-2.31:2
	>=x11-libs/gtk+-2.90:3
	>=dev-libs/dbus-glib-0.74
	>=sys-apps/dbus-1
	>=dev-libs/libxml2-2:2
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	ldap? ( net-nds/openldap )
	orbit? ( >=gnome-base/orbit-2.4:2 )
	policykit? ( sys-auth/polkit )"
DEPEND="${RDEPEND}
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1 )"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	G2CONF="${G2CONF}
		--enable-gtk
		--disable-static
		--enable-gsettings-backend
		--with-gtk=3.0
		$(use_enable introspection)
		$(use_with ldap openldap)
		$(use_enable orbit)
		$(use_enable policykit defaults-service)
		ORBIT_IDL=$(type -P orbit-idl-2)"
		# Need host's IDL compiler for cross or native build, bug #262747
	kill_gconf
}

src_prepare() {
	gnome2_src_prepare

	# Do not start gconfd when installing schemas, fix bug #238276, upstream #631983
	epatch "${FILESDIR}/${PN}-2.24.0-no-gconfd.patch"

	# Do not crash in gconf_entry_set_value() when entry pointer is NULL, upstream #631985
	epatch "${FILESDIR}/${PN}-2.28.0-entry-set-value-sigsegv.patch"

	# Don't try to link against modules
	epatch "${FILESDIR}"/${PN}-2.26.2-darwin-cant-link-module.patch
}

src_install() {
	gnome2_src_install

	keepdir /etc/gconf/gconf.xml.mandatory
	keepdir /etc/gconf/gconf.xml.defaults
	# Make sure this directory exists, bug #268070, upstream #572027
	keepdir /etc/gconf/gconf.xml.system

	echo 'CONFIG_PROTECT_MASK="/etc/gconf"' > 50gconf
	echo 'GSETTINGS_BACKEND="gconf"' >> 50gconf
	doenvd 50gconf
	dodir /root/.gconfd
}

pkg_preinst() {
	kill_gconf
}

pkg_postinst() {
	kill_gconf

	# change the permissions to avoid some gconf bugs
	einfo "changing permissions for gconf dirs"
	find  "${EPREFIX}"/etc/gconf/ -type d -exec chmod ugo+rx "{}" \;

	einfo "changing permissions for gconf files"
	find  "${EPREFIX}"/etc/gconf/ -type f -exec chmod ugo+r "{}" \;

	if ! use orbit; then
		ewarn "You are using dbus for GConf's IPC. If you are upgrading from"
		ewarn "<=gconf-3.2.3, or were previously using gconf with USE=orbit,"
		ewarn "you will need to now restart your desktop session (for example,"
		ewarn "by logging out and then back in)."
		ewarn "Otherwise, gconf-based applications may crash with 'Method ..."
		ewarn "on interface \"org.gnome.GConf.Server\" doesn't exist' errors."
	fi
}

kill_gconf() {
	# This function will kill all running gconfd-2 that could be causing troubles
	if [ -x "${EPREFIX}"/usr/bin/gconftool-2 ]
	then
		"${EPREFIX}"/usr/bin/gconftool-2 --shutdown
	fi

	return 0
}
