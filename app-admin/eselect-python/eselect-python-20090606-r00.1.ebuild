# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-20090606.ebuild,v 1.8 2009/08/25 17:31:16 arfrever Exp $

inherit eutils prefix

DESCRIPTION="Manages multiple Python versions"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="mirror://gentoo/python.eselect-${PV}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.2"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"
	epatch "${FILESDIR}"/${P}-mac.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify "${WORKDIR}"/python.eselect-${PV}
}

pkg_setup() {
	if has_version ">=app-admin/eselect-python-20090804"; then
		die "Downgrade of app-admin/eselect-python is not supported"
	fi
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/python.eselect-${PV}" python.eselect || die "newins python.eselect failed"
}
