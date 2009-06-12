# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xmlto/xmlto-0.0.22.ebuild,v 1.3 2009/06/10 13:56:22 flameeyes Exp $

EAPI=2
inherit eutils autotools

DESCRIPTION="A bash script for converting XML and DocBook formatted documents to a variety of output formats"
HOMEPAGE="https://fedorahosted.org/xmlto/browser"
SRC_URI="https://fedorahosted.org/releases/x/m/xmlto/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="latex"

RDEPEND="app-shells/bash
	dev-libs/libxslt
	>=app-text/docbook-xsl-stylesheets-1.62.0-r1
	~app-text/docbook-xml-dtd-4.2
	|| ( sys-apps/util-linux
		app-misc/getopt )
	|| ( || ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp )
		sys-freebsd/freebsd-ubin )
	latex? ( >=app-text/passivetex-1.25
		>=dev-tex/xmltex-1.9-r2 )"
DEPEND="${RDEPEND}
	sys-devel/flex"

src_prepare() {
	epatch "${FILESDIR}"/${P}-format_fo_passivetex_check.patch
	epatch "${FILESDIR}"/${P}-parallelmake.patch

	eautoreconf
}

src_configure() {
	local myconf
	has_version sys-apps/util-linux || myconf+="GETOPT=getopt-long"
	econf --prefix="${EPREFIX}"/usr BASH=${EPREFIX}/bin/bash ${myconf}
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" install || die "emake install failed"
	dodoc AUTHORS ChangeLog FAQ NEWS README THANKS
	insinto /usr/share/doc/${PF}/xml
	doins doc/*.xml
}
