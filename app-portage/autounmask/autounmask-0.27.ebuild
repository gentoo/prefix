# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/autounmask/autounmask-0.27.ebuild,v 1.8 2010/04/17 16:41:27 armin76 Exp $

inherit eutils prefix

DESCRIPTION="autounmask - Unmasking packages the easy way"
HOMEPAGE="http://download.mpsna.de/opensource/autounmask/"
SRC_URI="http://download.mpsna.de/opensource/autounmask/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
		>=dev-perl/PortageXS-0.02.09
		virtual/perl-Term-ANSIColor
		dev-perl/Shell-EnvImporter"
RDEPEND="${DEPEND}
		sys-apps/portage"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.26-prefix.patch
	epatch "${FILESDIR}"/${PN}-0.27-prefix.patch
	eprefixify autounmask
}

src_install() {
	dobin autounmask || die
	dodoc Changelog
}
