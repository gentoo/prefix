# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/orbit/orbit-2.14.7.ebuild,v 1.9 2007/06/02 02:42:37 ranger Exp $

EAPI="prefix"

inherit gnome2

MY_P="ORBit2-${PV}"
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="ORBit2 is a high-performance CORBA ORB"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/ORBit2/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8
	>=dev-libs/libIDL-0.8.2"

# FIXME linc is now integrated, but a block isn't necessary
# and probably complicated FIXME

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18
	doc? ( >=dev-util/gtk-doc-1 )"

MAKEOPTS="${MAKEOPTS} -j1"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README* TODO"

src_compile() {
	# We need to unset IDL_DIR, which is set by RSI's IDL.  This causes certain
	# files to be not found by autotools when compiling ORBit.  See bug #58540
	# for more information.  Please don't remove -- 8/18/06
	unset IDL_DIR

	gnome2_src_compile
}
