# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/xmlcopyeditor/xmlcopyeditor-1.2.0.2-r2.ebuild,v 1.1 2009/04/29 18:58:32 yoswink Exp $

EAPI="2"

WX_GTK_VER="2.8"

inherit wxwidgets eutils

DESCRIPTION="XML Copy Editor is a fast, free, validating XML editor"
HOMEPAGE="http://xml-copy-editor.sourceforge.net/"
SRC_URI="mirror://sourceforge/xml-copy-editor/${P}.tar.gz
		guidexml? ( mirror://gentoo/GuideXML-templates.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="guidexml"

DEPEND=">=dev-libs/libxml2-2.7.3-r1 \
		dev-libs/libxslt  \
		dev-libs/xerces-c \
		dev-libs/boost    \
		dev-libs/libpcre  \
		app-text/aspell   \
		x11-libs/wxGTK:2.8[X]"

RDEPEND=${DEPEND}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-1.2.0-Makefile.in-prefix.patch"
}

pkg_setup() {
	check_wxuse X
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use guidexml; then
		insinto /usr/share/xmlcopyeditor/templates/
		for TEMPLATE in "${WORKDIR}"/GuideXML-templates/*.xml; do
			newins "${TEMPLATE}" "${TEMPLATE##*/}" || die "GuideXML templates failed"
		done
	fi

	dodoc AUTHORS ChangeLog README NEWS
}
