# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/portage/portage-2.0.53_rc6.ebuild,v 1.1 2005/10/19 14:39:10 jstubbs Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="The Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~kito/distfiles/${PN}-${PV}.tar.gz"
LICENSE="GPL-2"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"

SLOT="0"
IUSE="build selinux"
DEPEND=">=dev-lang/python-2.2.1"
RDEPEND="!build? ( >=sys-apps/sed-4.0.5 dev-python/python-fchksum >=dev-lang/python-2.2.1 userland_GNU? ( sys-apps/debianutils ) >=app-shells/bash-2.05a ) !userland_Darwin? ( sys-apps/sandbox ) selinux? ( >=dev-python/python-selinux-2.15 )"
PROVIDE="virtual/portage"

S=${WORKDIR}/${PN}-${PV}


src_unpack() {
	unpack ${A}
}

src_compile() {
	econf --with-offset-prefix=${PREFIX} || die "econf failed"
	
	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	emake || die "emake failed"
}

src_install() {

	make DESTDIR=${DEST} install || die "make install failed."
	dodir /usr/lib/portage/bin
	dodir /etc/portage
	dodir /var/lib/portage
	keepdir /etc/portage

	doenvd ${FILESDIR}/05portage.envd
}

pkg_preinst() {
	if has livecvsportage ${FEATURES} && [ "${ROOT}" = "/" ]; then
		rm -rf ${IMAGE}/usr/lib/portage/pym/*
		mv ${IMAGE}/usr/lib/portage/bin/tbz2tool ${T}
		rm -rf ${IMAGE}/usr/lib/portage/bin/*
		mv ${T}/tbz2tool ${IMAGE}/usr/lib/portage/bin/
	else
		rm /usr/lib/portage/pym/*.pyc >& /dev/null
		rm /usr/lib/portage/pym/*.pyo >& /dev/null
	fi
}

pkg_postinst() {
	local x

	if [ ! -f "${ROOT}/var/lib/portage/world" ] &&
	   [ -f ${ROOT}/var/cache/edb/world ] &&
	   [ ! -h ${ROOT}/var/cache/edb/world ]; then
		mv ${ROOT}/var/cache/edb/world ${ROOT}/var/lib/portage/world
		ln -s ../../lib/portage/world /var/cache/edb/world
	fi

	for x in ${ROOT}etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${ROOT}etc/make.globals"
	done
}
