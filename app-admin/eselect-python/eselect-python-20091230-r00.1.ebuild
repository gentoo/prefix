# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-20091230.ebuild,v 1.5 2010/02/04 21:51:29 maekke Exp $

EAPI="1"

inherit toolchain-funcs flag-o-matic prefix

DESCRIPTION="Eselect module for management of multiple Python versions"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"
DEPEND="${RDEPEND}
	sys-devel/autoconf
	sparc-solaris? ( dev-libs/gnulib )"

pkg_setup() {
	if [[ ${CHOST} == *-solaris2.9 ]] ; then
		# solaris2.9 does not have scandir yet
		append-flags -I"${EPREFIX}/usr/$(get_libdir)/gnulib/include"
		append-ldflags -L"${EPREFIX}/usr/$(get_libdir)/gnulib/$(get_libdir)"
		append-libs -lgnu
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-20091230-mac.patch
	epatch "${FILESDIR}"/${PN}-20091230-prefix.patch
	epatch "${FILESDIR}"/${PN}-20091230-link-libs.patch
	epatch "${FILESDIR}"/${PN}-20091230-plain-c.patch
	eprefixify python.eselect
	./autogen.sh || die "autogen.sh failed"
}

src_compile() {
	use prefix && append-flags -DEPREFIX='"\"'"${EPREFIX}"'\""'
	econf || die
	emake || die
}

src_install() {
	keepdir /etc/env.d/python
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-20090804" || ! has_version "${CATEGORY}/${PN}"; then
		run_eselect_python_update="1"
	fi
}

pkg_postinst() {
	if [[ "${run_eselect_python_update}" == "1" ]]; then
		ebegin "Running \`eselect python update\`"
		eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 > /dev/null
		eend "$?"
	fi
}
