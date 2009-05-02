# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler-utils/poppler-utils-0.10.6.ebuild,v 1.1 2009/04/16 23:23:32 loki_val Exp $

EAPI=2

POPPLER_MODULE=utils

inherit poppler

DESCRIPTION="PDF conversion utilities"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+abiword"

RDEPEND="
	~dev-libs/poppler-${PV}[abiword?]
	abiword? ( >=dev-libs/libxml2-2.7.2 )
	!app-text/pdftohtml
	>=sys-devel/make-3.81-r00.1
	"
DEPEND="
	${RDEPEND}
	"

PATCHES=( "${FILESDIR}"/${P}-darwin-abiword-libxml2.patch )

pkg_setup() {
	POPPLER_CONF="$(use_enable abiword abiword-output)"
}
