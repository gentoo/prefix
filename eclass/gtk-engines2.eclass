# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gtk-engines2.eclass,v 1.15 2006/10/14 20:27:21 swegener Exp $

# IMPORTANT:
# This eclass is deprecated and should not be used in new ebuilds.

# Author: Alastair Tse <liquidx@gentoo.org>
#
# This is a utility eclass for installing GTK+ Theme Engines. It detects
# whether gtk+-1 and/or gtk+-2 is installed and sets up variables to help with
# installing the engines into the right position.
#
# Variables it sets are :
#
#  HAS_GTK1 / HAS_GTK2   -- simply if GTK+1 or GTK+2 is installed
#  GTK1_ENGINES_DIR      -- directory where gtk+1 engines are installed
#  GTK2_ENGINES_DIR      -- directory where gtk+2 engines are installed
#
# *** NOTE *** If your engine has both GTK+1 and GTK+2 versions :
#
#  Set the following variables if they are in different directories:
#
#  GTK1_S  -- GTK+1 Source Directory
#  GTK2_S  -- GTK+2 Source Directory
#
#  Also note you should not set DEPEND and let the eclass set the dependencies
#
# Comments:
#
# Most theme engines include ./configure scripts that solve most of the
# path problems. Sometimes there are certain versions that have trouble
# with paths. If they do, then you can use the above variables
#
# We do not employ USE flags "gtk" and "gtk2" because they are unsuitable
# in this case. We install the whole package of themes available, both
# GTK+1 and GTK+2 if available. We assume that the user would want both
# since the space savings are negligible.
#
# Note that this deals specifically with GTK ENGINES and not GTK THEMES. Some
# engines have themes that accompany them, and they are thus installed. You
# should not be using this eclass (it won't help anyway) if you are making
# a pure GTK+ theme ebuild.
#
# - liquidx@gentoo.org (16 Jun 2003)

inherit eutils


DESCRIPTION="GTK+1/2 ${PN/gtk-engines-} Theme Engine"
HOMEPAGE="http://art.gnome.org/ http://themes.freshmeat.net/"

# --- here we define some useful variables for gtk-engines installation

if has_version "=x11-libs/gtk+-1.2*"; then
	HAS_GTK1=1
	GTK1_ENGINES_DIR=/usr/$(get_libdir)/gtk/themes/engines
fi

if has_version ">=x11-libs/gtk+-2" || use gtk2; then
	HAS_GTK2=1
	GTK_VERSION=$(pkg-config --variable=gtk_binary_version gtk+-2.0)
	GTK2_ENGINES_DIR=/usr/$(get_libdir)/gtk-2.0/${GTK_VERSION}/engines
fi

# --- define some deps for binary packages
if [ -n "${HAS_GTK1}" -a ! -n "${HAS_GTK2}" ]; then
	DEPEND="${DEPEND} =x11-libs/gtk+-1.2*"
elif [ -n "${HAS_GTK1}" -a -n "${HAS_GTK2}" ]; then
	DEPEND="${DEPEND} =x11-libs/gtk+-1.2* =x11-libs/gtk+-2*"
elif [ ! -n "${HAS_GTK1}" -a -n "${HAS_GTK2}" ]; then
	DEPEND="${DEPEND} >=x11-libs/gtk+-2"
fi

# --- if we don't have any gtk version, we depend on USE flags to tell us
# --- which one to use. otherwise, we don't add any deps. make the ebuild
# --- tell us what DEPEND it wants.

if ! has_version "x11-libs/gtk+"; then
	DEPEND="gtk2? ( >=x11-libs/gtk+-2 ) !gtk2? ( =x11-libs/gtk+-1.2* )"
	use gtk2 \
		&& HAS_GTK2=1 \
		|| HAS_GTK1=1
fi

# --- if GTK1_S and GTK2_S is set, then we do both themes,
# --- otherwise, just do the normal src_compile/install wrap.

gtk-engines2_src_compile() {

	if [ -n "${GTK2_S}" -a -n "${GTK1_S}" ]; then
		if [ -n "${HAS_GTK2}" ]; then
			cd ${GTK2_S}
			econf || die "gtk2 configure failed"
			emake || die "gtk2 make failed"
		fi
		if [ -n "${HAS_GTK1}" ]; then
			cd ${GTK1_S}
			econf || die "gtk1 configure failed"
			emake || die "gtk1 make failed"
		fi
	else
		cd ${S}
		econf ${@} || die "configure failed"
		emake || make || die "make failed"
	fi
}

DEFAULT_DOCS="AUTHORS ChangeLog NEWS README"

gtk-engines2_src_install() {

	if [ -n "${GTK2_S}" -a -n "${GTK1_S}" ]; then
		if [ -n "${HAS_GTK2}" ]; then
			cd ${GTK2_S}
			make DESTDIR=${D} install || die "gtk2 install failed"
			for x in ${DEFAULT_DOCS} ${DOCS}; do
				newdoc ${x} ${x}.gtk2
			done
		fi
		if [ -n "${HAS_GTK1}" ]; then
			cd ${GTK1_S}
			make DESTDIR=${D} install || die "gtk1 install failed"
			for x in ${DEFAULT_DOCS} ${DOCS}; do
				newdoc ${x} ${x}.gtk1
			done
		fi
	else
		cd ${S}
		make DESTDIR=${D} ${@} install || die "install failed"
		dodoc ${DEFAULT_DOCS} ${DOCS}
	fi
}

EXPORT_FUNCTIONS src_compile src_install
