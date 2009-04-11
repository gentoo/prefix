# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/plan9port/plan9port-20080130.ebuild,v 1.1 2008/03/11 13:03:53 coldwind Exp $

inherit eutils

DESCRIPTION="Plan 9 From User Space"
HOMEPAGE="http://swtch.com/plan9port/"
SRC_URI="mirror://gentoo/${PN}-repack-${PV}.tar.bz2
	mirror://gentoo/${P}-paths.patch.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="!prefix? ( x11-base/xorg-server )"
RDEPEND=""

S="${WORKDIR}/plan9"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix shebangs (bug #209553) and all paths.
	epatch "${WORKDIR}"/${P}-paths.patch
}

src_compile() {
	einfo "                                                             "
	einfo "Compiling Plan 9 from User Space can take a very long time   "
	einfo "depending on the speed of your computer. Please be patient!  "
	einfo "                                                             "
	./INSTALL -b
}

src_install() {
	dodir /usr/lib/plan9
	mv "${S}" "${ED}"/usr/lib/
	sed "s:=:=${EPREFIX}:" "${FILESDIR}/30plan9" > "${T}"/30plan9
	doenvd "${T}"/30plan9
}

pkg_postinst() {
	einfo "                                                             "
	einfo "Recalibrating Plan 9 from User Space to its new environment. "
	einfo "This could take a while...                                   "
	einfo "                                                             "

	cd "${EPREFIX}"/usr/lib/plan9
	export PATH="$PATH:${EPREFIX}/usr/lib/plan9"
	./INSTALL -c &> /dev/null

	elog "                                                             "
	elog "Plan 9 from User Space has been successfully installed into  "
	elog "/usr/lib/plan9. Your PLAN9 and PATH environment variables    "
	elog "have also been appropriately set, please use env-update and  "
	elog "source /etc/profile to bring that into immediate effect.     "
	elog "                                                             "
	elog "Please note that \${PLAN9}/bin has been appended to the *end*"
	elog "or your PATH to prevent conflicts. To use the Plan9 versions "
	elog "of common UNIX tools, use the absolute path:                 "
	elog "/usr/lib/plan9/bin or the 9 command (eg: 9 troff)            "
	elog "                                                             "
	elog "Please report any bugs to bugs.gentoo.org, NOT Plan9Port.    "
	elog "                                                             "
}
