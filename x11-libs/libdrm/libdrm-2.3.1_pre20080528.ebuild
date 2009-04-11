# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.3.1_pre20080528.ebuild,v 1.1 2008/06/10 07:37:50 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit autotools x-modular git

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"
EGIT_BOOTSTRAP="eautoreconf"
EGIT_BRANCH="libdrm-2_3-branch"
EGIT_TREE="6a30539814fe20ff25e8f853c2e212f9ebadfadc"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
SRC_URI=""

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
