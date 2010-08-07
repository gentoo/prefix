# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libproxy/libproxy-0.4.2.ebuild,v 1.5 2010/07/15 16:19:15 jer Exp $

EAPI="2"
CMAKE_MIN_VERSION="2.8"
PYTHON_DEPEND="python? 2:2.5"

inherit cmake-utils eutils multilib python portability

DESCRIPTION="Library for automatic proxy configuration management"
HOMEPAGE="http://code.google.com/p/libproxy/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="debug gnome kde networkmanager perl python vala webkit xulrunner"

RDEPEND="
	gnome? ( gnome-base/gconf )
	kde? ( >=kde-base/kdelibs-4.3 )
	networkmanager? ( net-misc/networkmanager )
	perl? (	dev-lang/perl )
	vala? ( dev-lang/vala )
	webkit? ( net-libs/webkit-gtk )
	xulrunner? ( >=net-libs/xulrunner-1.9.0.11-r1:1.9 )
	x86-interix? ( sys-libs/itx-bind )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

DOCS="AUTHORS NEWS README ChangeLog"

pkg_setup() {
	if use python; then
		python_set_active_version 2
	fi
}

src_prepare() {
	base_src_prepare
	if use debug; then
	  sed "s/-g -Wall -Werror /-g -Wall /" CMakeLists.txt -i
	else
	  sed "s/-g -Wall -Werror / /" CMakeLists.txt -i
	fi
	# Stop using xulrunner 1.8 when both are installed
	epatch "${FILESDIR}"/libproxy-0.4.2-mozjs-search-order.patch
}

src_configure() {
	[[ ${CHOST} == *-solaris* ]] && append-libs -lsocket -lnsl
	if [[ ${CHOST} == *-interix* ]]; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
		append-libs -lbind -ldl
	fi

	mycmakeargs=(
			-DPERL_VENDORINSTALL=ON
			-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
			-DCMAKE_LD_FLAGS="${CXXFLAGS}"
			$(cmake-utils_use_with gnome GNOME)
			$(cmake-utils_use_with kde KDE4)
			$(cmake-utils_use_with networkmanager NM)
			$(cmake-utils_use_with perl PERL)
			$(cmake-utils_use_with python PYTHON)
			$(cmake-utils_use_with vala VALA)
			$(cmake-utils_use_with webkit WEBKIT)
			$(cmake-utils_use_with xulrunner MOZJS)
	)
	cmake-utils_src_configure
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libproxy.so.0
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libproxy.so.0

	if use python; then
		python_need_rebuild
		python_mod_optimize $(python_get_sitedir)/${PN}.py
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup $(python_get_sitedir)/${PN}.py
	fi
}
