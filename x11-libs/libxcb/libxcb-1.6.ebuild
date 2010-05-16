# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.6.ebuild,v 1.2 2010/04/25 14:56:02 chithanh Exp $

EAPI=3

inherit python xorg-2 eutils prefix

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/libxcb"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc selinux"

RDEPEND="x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt
	>=x11-proto/xcb-proto-1.6
	=dev-lang/python-2*[xml]"

pkg_setup() {
	python_set_active_version 2
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable doc build-docs)
		$(use_enable selinux)
		--enable-xinput"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.4-interix.patch
	epatch "${FILESDIR}"/${PN}-1.4-interix-ipv6.patch

	cp "${FILESDIR}"/xcb-rebuilder.sh "${T}"/ || die
	eprefixify "${T}"/xcb-rebuilder.sh
}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	default_src_configure || die
}
