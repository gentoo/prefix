# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xmms-plugin.eclass,v 1.22 2006/06/28 09:36:30 metalgod Exp $
#
# Jeremy Huddleston <eradicator@gentoo.org>
# Luis Medinas	<metalgod@gentoo.org>

# Usage:
# This eclass is used to create ebuilds for xmms plugins which are contained
# within the main xmms tarball.  Usage:

# PATCH_VER:
# M4_VER:
# GENTOO_URI:
GENTOO_URI=${GENTOO_URI-"http://dev.gentoo.org/~metalgod/xmms"}
# Set this variable if you want to use a gentoo specific patchset.  This adds
# ${GENTOO_URI}/xmms-${PV}-gentoo-patches-${PATCH_VER}.tar.bz2 to the SRC_URI

# PLUGIN_PATH:
# Set this variable to the plugin location you want to build.
# Example:
# PLUGIN_PATH="Input/mpg123"

# SONAME:
# Set this variable to the filename of the plugin that is copied over
# Example:
# SONAME="libmpg123.so"

inherit eutils flag-o-matic

DESCRIPTION="Xmms Plugin: ${PN}"
HOMEPAGE="http://www.xmms.org"
LICENSE="GPL-2"

SRC_URI="http://www.xmms.org/files/1.2.x/xmms-${PV}.tar.bz2
	 ${M4_VER:+${GENTOO_URI}/xmms-${PV}-gentoo-m4-${M4_VER}.tar.bz2}
	 ${PATCH_VER:+${GENTOO_URI}/xmms-${PV}-gentoo-patches-${PATCH_VER}.tar.bz2}"

# Set S to something which exists
S="${WORKDIR}/xmms-${PV}"

RDEPEND="${RDEPEND+${RDEPEND}}${RDEPEND-${DEPEND}}"
DEPEND="${DEPEND}
	=sys-devel/automake-1.7*
	>=sys-devel/autoconf-2.59
	sys-devel/libtool"

xmms-plugin_src_unpack() {
	if ! has_version '>=media-sound/xmms-1.2.10-r13'; then
		ewarn "You don't have >=media-sound/xmms-1.2.10-r13, so we are using the SDK in"
		ewarn "this package rather that the one installed on your system. It is recommended"
		ewarn "that you cancel this emerge and grab >=media-sound/xmms-1.2.10-r13 first."
		epause 5
	fi

	unpack ${A}

	cd ${S}
	if [[ -n "${PATCH_VER}" ]]; then
		EPATCH_SUFFIX="patch"
		epatch ${WORKDIR}/patches
	fi

	cd ${S}/${PLUGIN_PATH}
	sed -i -e "s:-I\$(top_srcdir)::g" \
	       -e "s:\$(top_builddir)/libxmms/libxmms.la:/usr/$(get_libdir)/libxmms.la:g" \
	       Makefile.am || die "Failed to edit Makefile.am"

	cd ${S}

	export WANT_AUTOMAKE=1.7
	export WANT_AUTOCONF=2.5

	libtoolize --force --copy || die "libtoolize --force --copy failed"

	if [[ -n "${M4_VER}" ]]; then
		rm acinclude.m4
		aclocal -I ${WORKDIR}/m4 || die "aclocal failed"
	else
		aclocal || die "aclocal failed"
	fi
	autoheader || die "autoheader failed"
	automake --gnu --add-missing --include-deps --force-missing --copy || die "automake failed"

	cd ${S}/${PLUGIN_PATH}
	if has_version '>=media-sound/xmms-1.2.10-r13'; then
		sed -i -e "s:^DEFAULT_INCLUDES = .*$:DEFAULT_INCLUDES = -I. $(xmms-config --cflags):" \
			Makefile.in || die "Failed to edit Makefile.in"
	fi

	cd ${S}
	autoconf || die "autoconf failed"
}

xmms-plugin_src_compile() {
	filter-flags -fforce-addr -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE

	econf ${myconf}
	cp config.h ${S}/${PLUGIN_PATH}

	cd ${S}/${PLUGIN_PATH}
	emake -j1 || die
}

xmms-plugin_src_install() {
	cd ${S}/${PLUGIN_PATH}
	make DESTDIR="${D}" install || die
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
