# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/orbit/orbit-2.14.12.ebuild,v 1.9 2008/04/20 01:36:05 vapier Exp $

EAPI="prefix"

inherit gnome2 eutils

MY_P="ORBit2-${PV}"
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="ORBit2 is a high-performance CORBA ORB"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/ORBit2/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8
	>=dev-libs/libIDL-0.8.2"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18
	doc? ( >=dev-util/gtk-doc-1 )"

MAKEOPTS="${MAKEOPTS} -j1"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README* TODO"

src_unpack() {
	gnome2_src_unpack

	# Filter out G_DISABLE_DEPRECATED to be future-proof, related to bug 213434
	sed -i -e '/DISABLE_DEPRECATED/d' \
		"${S}/linc2/src/Makefile.am" "${S}/linc2/src/Makefile.in"

	sed -i -e 's:-DG_DISABLE_DEPRECATED::g' \
		"${S}/configure.in" "${S}/configure"

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	# We need to unset IDL_DIR, which is set by RSI's IDL.  This causes certain
	# files to be not found by autotools when compiling ORBit.  See bug #58540
	# for more information.  Please don't remove -- 8/18/06
	unset IDL_DIR

	# on interix poll is broken!
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	gnome2_src_compile
}
