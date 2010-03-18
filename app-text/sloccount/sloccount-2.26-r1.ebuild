# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sloccount/sloccount-2.26-r1.ebuild,v 1.12 2008/12/09 21:33:31 armin76 Exp $

inherit eutils

DESCRIPTION="Tools for counting Source Lines of Code (SLOC) for a large number of languages"
HOMEPAGE="http://www.dwheeler.com/sloccount/"
SRC_URI="http://www.dwheeler.com/sloccount/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""
RDEPEND="dev-lang/perl
		>=sys-apps/sed-4
		app-shells/bash"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-libexec.patch
	epatch "${FILESDIR}"/${P}-coreutils-tail-n-fix.patch
	epatch "${FILESDIR}"/${PN}-2.26-prefix-libexec.patch

	sed -i \
		-e "/^CC/ { s/$/ ${CFLAGS}/g }" \
		-e "/^DOC_DIR/ { s/-\$(RPM_VERSION)//g }" \
		-e "/^MYDOCS/ { s/[^    =]\+\.html//g }" \
		makefile || die "sed makefile failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall PREFIX="${ED}/usr" DOC_DIR="${ED}/usr/share/doc/${PF}/" || die
	prepalldocs
	dohtml *html
}
