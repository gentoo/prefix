# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/plan9port/plan9port-20070522.ebuild,v 1.3 2009/03/20 17:43:23 jmbsvicetto Exp $

DESCRIPTION="Plan 9 From User Space"
HOMEPAGE="http://swtch.com/plan9port/"
SRC_URI="http://www.kix.in/plan9/${PN}-repack-${PV}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="!prefix? ( x11-base/xorg-server )"
RDEPEND=""

S="${WORKDIR}/plan9"

src_compile() {
	einfo "                                                             "
	einfo "Compiling Plan 9 from User Space can take a very long time   "
	einfo "depending on the speed of your computer. Please be patient!  "
	einfo "                                                             "
	./INSTALL -b
}

src_install() {
	dodir /usr/lib/plan9
	mv "${S}" "${ED}/usr/lib/"
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

	einfo "                                                             "
	einfo "Plan 9 from User Space has been successfully installed into  "
	einfo "/usr/lib/plan9. Your PLAN9 and PATH environment variables    "
	einfo "have also been appropriately set, please use env-update and  "
	einfo "source /etc/profile to bring that into immediate effect.     "
	einfo "                                                             "
	einfo "Please note thet PLAN9/bin has been appended to the *end* of "
	einfo "your PATH to prevent conflicts. To use the Plan9 versions of "
	einfo "common UNIX tools, use the absolute path: /usr/lib/plan9/bin "
	einfo "or the 9 command (eg: 9 troff)                               "
	einfo "                                                             "
	einfo "Please report any bugs to bugs.gentoo.org, NOT Plan9Port.    "
	einfo "                                                             "
}
