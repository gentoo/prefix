# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-2-r1.ebuild,v 1.1 2010/08/15 05:14:35 vapier Exp $

inherit eutils toolchain-funcs prefix

DESCRIPTION="Utility to change the binutils version being used - prefix version"
HOMEPAGE="http://www.gentoo.org/"
W_VER="0.3.1668"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/toolchain-prefix-wrapper-${W_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="sunld"

RDEPEND=">=sys-apps/findutils-4.2
	>=sys-devel/gcc-config-1.4.0"

S=${WORKDIR}/toolchain-prefix-wrapper-${W_VER}

src_unpack() {
	unpack ${A}
	cd "${S}"
	cp "${FILESDIR}"/${P} ./${PN} || die "cannot gain ${FILESDIR}/${P}"
	epatch "${FILESDIR}"/1.9-extwrapper.patch
	# this patch seems only to be needed for sunld, but that one got its own
	# plugin now, so it feels unneeded to me
	#epatch "${FILESDIR}"/${P}-libpath-ordering.patch
	# to mduft: why isn't this patch just applied upstream?
	use sunld && epatch "${FILESDIR}"/${P}-solaris-native-ld.patch
	eprefixify ${PN} || die "eprefixify failed."
}

src_compile() {
	econf --with-macosx-version-min=${MACOSX_DEPLOYMENT_TARGET}
	emake || die "emake failed."
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed."
	dobin ${PN} || die "cannot install ${PN} script."
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(${EROOT}/usr/bin/binutils-config --get-current-profile)
	fi
}
