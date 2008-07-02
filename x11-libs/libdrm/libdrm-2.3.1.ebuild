# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.3.1.ebuild,v 1.1 2008/07/01 08:32:48 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
SRC_URI="http://dri.freedesktop.org/libdrm/${P}.tar.gz"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

RDEPEND=""
DEPEND="${RDEPEND}"

pkg_preinst() {
	x-modular_pkg_preinst

	if [[ -e ${EROOT}/usr/$(get_libdir)/libdrm.so.1 ]] ; then
		cp -pPR "${EROOT}"/usr/$(get_libdir)/libdrm.so.{1,1.0.0} "${ED}"/usr/$(get_libdir)/
	fi
}

pkg_postinst() {
	x-modular_pkg_postinst

	if [[ -e ${EROOT}/usr/$(get_libdir)/libdrm.so.1 ]] ; then
		elog "You must re-compile all packages that are linked against"
		elog "libdrm 1 by using revdep-rebuild from gentoolkit:"
		elog "# revdep-rebuild --library libdrm.so.1"
		elog "After this, you can delete /usr/$(get_libdir)/libdrm.so.1"
		elog "and /usr/$(get_libdir)/libdrm.so.1.0.0 ."
		epause
	fi
}
