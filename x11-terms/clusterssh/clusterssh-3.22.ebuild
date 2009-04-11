# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/clusterssh/clusterssh-3.22.ebuild,v 1.1 2008/09/17 11:40:19 tantive Exp $

inherit eutils

DESCRIPTION="Concurrent Multi-Server Terminal Access."
HOMEPAGE="http://clusterssh.sourceforge.net"
SRC_URI="mirror://sourceforge/clusterssh/clusterssh-${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=dev-lang/perl-5.6.1
	dev-perl/perl-tk
	dev-perl/Config-Simple
	dev-perl/X11-Protocol
	x11-apps/xlsfonts"

src_unpack() {
	unpack "${A}"
#	epatch "${FILESDIR}"/${PN}-3.21-xrm-remove-class.patch

	# WARNING: this patch removes help from the main window!!
	# if help is needed, don't apply this (won't build on interix).
	# help is nothing else than "man cssh" in a GUI window.
#patch fails, interix peepz need to fix it
#	epatch "${FILESDIR}"/${PN}-3.21-interix.patch
}

src_compile() {
	# Gentoo perl ebuilds remove podchecker
	if grep -v podchecker "${S}"/src/Makefile.in \
		> "${S}"/src/Makefile.in.new; then
		mv "${S}"/src/Makefile.in.new "${S}"/src/Makefile.in
	else
		die "Makefile.in update failed"
	fi

	econf || die "configuration failed"
	emake || die "compiling failed"
}

src_install() {
	dodoc AUTHORS COPYING INSTALL NEWS README THANKS
	dobin src/cssh
	doman src/cssh.1
}
