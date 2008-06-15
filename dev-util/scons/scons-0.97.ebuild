# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/scons/scons-0.97.ebuild,v 1.10 2008/06/14 11:45:06 zmedico Exp $

EAPI="prefix"

NEED_PYTHON="1.5.2"

inherit python distutils multilib

DESCRIPTION="Extensible Python-based build utility"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.scons.org/"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DOCS="RELEASE.txt CHANGES.txt LICENSE.txt"

src_install () {
	distutils_src_install
	# move man pages from /usr/man to /usr/share/man
	dodir /usr/share
	mv "${ED}"/usr/man "${ED}"/usr/share
}

pkg_preinst() {
	has_version "<${CATEGORY}/${PN}-0.96.92-r1"
	clean_stale_junk=$?
}

pkg_postinst() {
	python_mod_optimize /usr/$(get_libdir)/${P}
	# clean up stale junk left there by old faulty ebuilds
	# see Bug 118022 and Bug 132448
	if [[ $clean_stale_junk = 0 ]] ; then
		einfo "Cleaning up stale orphaned py[co] files..."
		[[ -d "${EROOT}/usr/$(get_libdir)/scons/SCons" ]] \
		    && rm -rf "${EROOT}/usr/$(get_libdir)/scons/SCons"
		einfo "Done."
	fi
}

pkg_postrm() {
	python_mod_cleanup "${EPREFIX}"/usr/$(get_libdir)/${P}
}
