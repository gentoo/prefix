# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/python-updater/python-updater-0.9-r1.ebuild,v 1.1 2011/08/29 10:28:31 naota Exp $

inherit eutils multilib

DESCRIPTION="Script used to reinstall Python packages after changing of active Python versions"
HOMEPAGE="http://www.gentoo.org/proj/en/Python"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python
	|| ( >=sys-apps/portage-2.1.6 >=sys-apps/paludis-0.56.0 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-sed.patch

	epatch "${FILESDIR}"/${P}-prefix.patch
	ebegin "Adjusting to prefix"
	sed -i \
		-e "s:@GENTOO_PORTAGE_EPREFIX@:${EPREFIX}:g" \
		-e "s:@GENTOO_PORTAGE_LIBSUFFIX@:$(get_libname):g" \
		"${PN}" || die "prefixifying failed"
	eend $?
}

src_install() {
	dosbin ${PN} || die "dosbin failed"
	doman ${PN}.1 || die "doman failed"
	dodoc AUTHORS || die "dodoc failed"
}
