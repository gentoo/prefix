# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit-dev/gentoolkit-dev-0.2.6.13.ebuild,v 1.2 2009/11/12 20:12:46 idl0r Exp $

EAPI="2"

DESCRIPTION="Collection of developer scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/python[xml]"
RDEPEND="${DEPEND}
	sys-apps/portage
	dev-lang/perl"

src_prepare() {
	# prefixify shebangs
	sed -i -e '1s:^#! \?:#!'"${EPREFIX}"':' \
		src/ebump/ebump \
		src/echangelog/echangelog \
		src/ekeyword/ekeyword \
		src/eshowkw/eshowkw \
		src/eviewcvs/eviewcvs \
		src/imlate/imlate
}

src_prepare() {
	sed -i -e 's:sh test:bash test:' src/echangelog/Makefile || die
}

src_test() {
	# echangelog test is not able to run as root
	# the EUID check may not work for everybody
	if [[ ${EUID} -ne 0 ]];
	then
		emake test || die
	else
		ewarn "test skipped, please re-run as non-root if you wish to test ${PN}"
	fi
}

src_install() {
	emake DESTDIR="${D}${EPREFIX}" install || die
}
