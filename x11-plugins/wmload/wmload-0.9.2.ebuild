# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/wmload/wmload-0.9.2.ebuild,v 1.9 2008/06/29 13:26:03 drac Exp $

EAPI="prefix"

inherit eutils flag-o-matic

IUSE=""

DESCRIPTION="yet another dock application showing a system load gauge"
SRC_URI="http://www.cs.mun.ca/~gstarkes/wmaker/dockapps/files/${P}.tgz"
HOMEPAGE="http://www.cs.mun.ca/~gstarkes/wmaker/dockapps/sys.html#wmload"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXpm"
DEPEND="${RDEPEND}
	x11-misc/imake
	x11-proto/xproto
	x11-proto/xextproto"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}"/${PN}-ComplexProgramTargetNoMan.patch
	epatch "${FILESDIR}"/${PN}.solaris.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	[[ ${CHOST} == *-solaris* ]] && \
		sed -i -e 's/\(^XPMLIB = \)\(.*$\)/\1-lkstat \2/' Imakefile
}

src_compile() {
	xmkmf || die "xmkmf failed."
	emake CDEBUGFLAGS="${CFLAGS}" || die "emake failed."
}

src_install() {
	einstall DESTDIR="${D}" BINDIR="${EPREFIX}"/usr/bin || die "einstall failed."

	dodoc README

	insinto /usr/share/applications
	doins "${FILESDIR}"/${PN}.desktop
}
