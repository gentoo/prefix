# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgamin/libgamin-0.1.10-r2.ebuild,v 1.8 2009/04/12 20:40:18 bluebird Exp $

EAPI=2

inherit autotools eutils flag-o-matic libtool python

MY_PN=${PN//lib/}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/${MY_PN}/sources/${MY_P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug kernel_linux python"

RESTRICT="test" # need gam-server

RDEPEND="python? ( virtual/python )
	!app-admin/fam
	!<app-admin/gamin-0.1.10"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Fix QA warnings, bug #257281, upstream #466791
	epatch "${FILESDIR}/${P}-compilewarnings.patch"

	# Fix compile warnings; bug #188923
	[[ ${CHOST} != *-solaris* ]] && \
	epatch "${FILESDIR}/${MY_PN}-0.1.9-freebsd.patch"

	# Fix collision problem due to intermediate library, upstream bug #530635
	epatch "${FILESDIR}/${P}-noinst-lib.patch"

	# (Open)Solaris necessary patches (changes configure.in), unfortunately
	# conflicts with freebsd patch and breaks some linux installs so it must
	# only be applied if on solaris.
	[[ ${CHOST} == *-solaris* ]] && \
	epatch "${FILESDIR}"/${P}-opensolaris.patch

	# autoconf is required as the user-cflags patch modifies configure.in
	# however, elibtoolize is also required, so when the above patch is
	# removed, replace the following call with a call to elibtoolize
	eautoreconf

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

src_configure() {
	econf --disable-debug \
		--disable-server \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug debug-api) \
		$(use_with python)
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"

	dodoc AUTHORS ChangeLog README TODO NEWS doc/*txt || die "dodoc failed"
	dohtml doc/* || die "dohtml failed"
}

pkg_postinst() {
	if use python; then
		python_version
		python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages
}
