# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libproxy/libproxy-0.2.3-r2.ebuild,v 1.7 2009/10/31 14:09:27 ranger Exp $

EAPI="2"

inherit autotools eutils python portability flag-o-matic

DESCRIPTION="Library for automatic proxy configuration management"
HOMEPAGE="http://code.google.com/p/libproxy/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="gnome kde networkmanager python seamonkey webkit xulrunner"

RDEPEND="
	gnome? (
		x11-libs/libX11
		x11-libs/libXmu
		gnome-base/gconf )
	kde? (
		x11-libs/libX11
		x11-libs/libXmu )
	networkmanager? ( net-misc/networkmanager )
	python? ( >=dev-lang/python-2.5 )
	webkit? ( net-libs/webkit-gtk )
	xulrunner? ( >=net-libs/xulrunner-1.9.0.11-r1:1.9 )
	!xulrunner? ( seamonkey? ( www-client/seamonkey ) )
	x86-interix? ( sys-libs/itx-bind )
"
# Since xulrunner-1.9.0.11-r1 its shipped mozilla-js.pc is fixed so we can use it

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_prepare() {
	# http://code.google.com/p/libproxy/issues/detail?id=23
	epatch "${FILESDIR}/${P}-fix-dbus-includes.patch"

	# http://code.google.com/p/libproxy/issues/detail?id=24
	epatch "${FILESDIR}/${P}-fix-python-automagic.patch"

	# http://code.google.com/p/libproxy/issues/detail?id=25
	epatch "${FILESDIR}/${P}-fix-as-needed-problem.patch"

	# Bug 275127 and 275318
	epatch "${FILESDIR}/${P}-fix-automagic-mozjs.patch"

	# Fix implicit declaration QA, bug #268546
	epatch "${FILESDIR}/${P}-implicit-declaration.patch"

	epatch "${FILESDIR}/${P}-fbsd.patch" # drop at next bump

	# Fix test to follow POSIX (for x86-fbsd).
	# FIXME: This doesn't actually fix all == instances when two are on the same line
	sed -e 's/\(test.*\)==/\1=/g' -i configure.ac configure || die "sed failed"

	# Fix building on platforms that do not define INET_ADDRSTRLEN
	epatch "${FILESDIR}/${P}-addrstrlen.patch"

	# fix interix build with no ipv6...
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${P}-interix5.patch

	eautoreconf
}

src_configure() {
	local myconf

	# xulrunner:1.9 => mozilla;   seamonkey => seamonkey;
	# xulrunner:1.8 => xulrunner; (firefox => mozilla-firefox[-xulrunner] ?)
	if use xulrunner; then myconf="--with-mozjs=mozilla"
	elif use seamonkey; then myconf="--with-mozjs=seamonkey"
	else myconf="--without-mozjs"
	fi

	[[ ${CHOST} == *-solaris* ]] && append-libs -lsocket -lnsl
	if [[ ${CHOST} == *-interix* ]]; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
		append-libs -lbind -ldl
	fi

	econf --with-envvar \
		--with-file \
		--disable-static \
		$(use_with gnome) \
		$(use_with kde) \
		$(use_with webkit) \
		$(use_with xulrunner mozjs) \
		${myconf} \
		$(use_with networkmanager) \
		$(use_with python)
}

src_compile() {
	emake LIBDL="$(dlopen_lib)" || die
}

src_install() {
	emake DESTDIR="${D}" LIBDL="$(dlopen_lib)" install || die "emake install failed!"
	dodoc AUTHORS NEWS README ChangeLog || die "dodoc failed"
}

pkg_postinst() {
	if use python; then
		python_need_rebuild
		python_mod_optimize "$(python_get_sitedir)/${PN}.py"
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/${PN}.py
}
