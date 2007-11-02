# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r4.ebuild,v 1.1 2007/05/06 09:04:01 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Utility to change the binutils version being used - prefix version"
HOMEPAGE="http://www.gentoo.org/"
W_VER="0.1.0.1593"
SRC_URI="http://dev.gentoo.org/~haubi/distfiles/toolchain-prefix-wrapper-${W_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ia64-hpux ~ppc-aix"
IUSE=""

RDEPEND=">=sys-apps/findutils-4.2"

S="${WORKDIR}/toolchain-prefix-wrapper-${W_VER}"

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}"/${PN}-${PV}-old "${T}"/${PN}-${PV} \
	|| die "cannot cp ${PN}-${PV}"
	eprefixify "${T}"/${PN}-${PV}
}

src_compile() {
	econf --bindir="${EPREFIX}"/usr/lib/misc
	emake || die "emake failed."
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed."
	mv "${ED}"/usr/$(get_libdir)/misc/{prefixld,binutils-config} \
	|| die "Cannot rename prefixld to binutils-config"

	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(${EROOT}/usr/bin/binutils-config --get-current-profile)
	fi
}
