# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/orbit/orbit-2.14.18.ebuild,v 1.2 2010/05/04 16:11:45 tester Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 toolchain-funcs eutils autotools

MY_P="ORBit2-${PV}"
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="ORBit2 is a high-performance CORBA ORB"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/ORBit2/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8
	>=dev-libs/libIDL-0.8.2"

DEPEND="
	>=dev-util/pkgconfig-0.18
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README* TODO"

src_unpack() {
	gnome2_src_unpack

	epatch "${FILESDIR}"/${PN}-2.14.14-interix.patch
	epatch "${FILESDIR}"/${PN}-2.14.16-interix.patch
	epatch "${FILESDIR}"/${PN}-2.14.17-interix.patch

	if [[ ${CHOST} == *-winnt* ]]; then 
		epatch "${FILESDIR}"/${PN}-2.14.16-winnt.patch
		epatch "${FILESDIR}"/${PN}-2.14.17-winnt.patch

		# avoid needing dev-util/gtk-doc for eautoreconf only
		use doc || : > gtk-doc.make
		use doc || sed -i -e 's,GTK_DOC_CHECK,#&,' configure.in
		eautoreconf
	fi
}

src_prepare() {
	gnome2_src_prepare

	# Fix wrong process kill, bug #268142
	sed "s:killall lt-timeout-server:killall timeout-server:" \
		-i test/timeout.sh || die "sed failed"
}

src_compile() {
	# We need to unset IDL_DIR, which is set by RSI's IDL.  This causes certain
	# files to be not found by autotools when compiling ORBit.  See bug #58540
	# for more information.  Please don't remove -- 8/18/06
	unset IDL_DIR

	# on interix poll is broken!
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	# We need to use the hosts IDL compiler if cross-compiling, bug #262741
	if tc-is-cross-compiler; then
		# check that host version is present and executable
		[ -x "${EPREFIX}"/usr/bin/orbit-idl-2 ] || die "Please emerge ~${CATEGORY}/${P} on the host system first"
		G2CONF="${G2CONF} --with-idl-compiler=${EPREFIX}/usr/bin/orbit-idl-2"
	fi

	gnome2_src_compile
}

src_test() {
	# can fail in parallel, see bug #235994
	emake -j1 check || die "tests failed"
}
