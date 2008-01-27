# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.4.ebuild,v 1.2 2008/01/22 23:15:31 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/lzma-${PV/_}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!app-arch/lzma"

S=${WORKDIR}/lzma-${PV/_}

pkg_setup() {
	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=20366
	[[ ${CHOST} == *-aix* ]] && export ac_cv_sys_large_files=no
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
