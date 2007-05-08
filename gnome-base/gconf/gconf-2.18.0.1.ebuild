# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gconf/gconf-2.18.0.1.ebuild,v 1.1 2007/03/30 21:24:45 remi Exp $

EAPI="prefix"

inherit gnome2

MY_PN=GConf
MY_P=${MY_PN}-${PV}
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="Gnome Configuration System and Daemon"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.10
	>=x11-libs/gtk+-2.8.16
	>=gnome-base/orbit-2.4
	>=dev-libs/libxml2-2
	dev-libs/popt"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1 )"

# FIXME : consider merging the tree (?)
DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} --enable-gtk"
	kill_gconf
}

src_install() {
	gnome2_src_install

	# hack hack
	dodir /etc/gconf/gconf.xml.mandatory
	dodir /etc/gconf/gconf.xml.defaults
	touch "${ED}"/etc/gconf/gconf.xml.mandatory/.keep${SLOT}
	touch "${ED}"/etc/gconf/gconf.xml.defaults/.keep${SLOT}

	echo 'CONFIG_PROTECT_MASK="/etc/gconf"' > 50gconf
	doenvd 50gconf || die
	dodir /root/.gconfd
}

kill_gconf() {
	# this function will kill all running gconfd that could be causing troubles
	if [ -x "${EPREFIX}"/usr/bin/gconftool ]
	then
		"${EPREFIX}"/usr/bin/gconftool --shutdown
	fi
	if [ -x "${EPREFIX}"/usr/bin/gconftool-1 ]
	then
		"${EPREFIX}"/usr/bin/gconftool-1 --shutdown
	fi

	# and for gconf 2
	if [ -x "${EPREFIX}"/usr/bin/gconftool-2 ]
	then
		"${EPREFIX}"/usr/bin/gconftool-2 --shutdown
	fi
	return 0
}

pkg_preinst() {
	kill_gconf
}

pkg_postinst() {
	kill_gconf

	#change the permissions to avoid some gconf bugs
	einfo "changing permissions for gconf dirs"
	find  "${EPREFIX}"/etc/gconf/ -type d -exec chmod ugo+rx "{}" \;
	einfo "changing permissions for gconf files"
	find  "${EPREFIX}"/etc/gconf/ -type f -exec chmod ugo+r "{}" \;
}
