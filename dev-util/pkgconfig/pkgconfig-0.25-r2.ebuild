# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.25-r2.ebuild,v 1.2 2010/07/15 08:07:11 ssuominen Exp $

EAPI=2
inherit eutils flag-o-matic libtool

MY_P=pkg-config-${PV}

DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"
SRC_URI="http://pkgconfig.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="elibc_FreeBSD hardened"

DEPEND=">=dev-libs/popt-1.15"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-dnl.patch
	elibtoolize # for FreeMiNT, bug #333429
}

src_configure() {
	use ppc64 && use hardened && replace-flags -O[2-3] -O1

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	local myconf
	use elibc_FreeBSD && myconf="--enable-indirect-deps"

	if [[ ${CHOST} == *-interix* ]]; then 
		export ac_cv_func_poll=no
	fi

	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--with-installed-popt \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS README

	echo "PKG_CONFIG_PATH=${EPREFIX}/usr/lib/pkgconfig:${EPREFIX}/usr/share/pkgconfig" >> "${T}"/99${PN}
	doenvd "${T}"/99${PN}
}
