# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/xmlcopyeditor/xmlcopyeditor-1.2.0.6.ebuild,v 1.2 2010/08/23 07:02:15 tove Exp $

EAPI="2"

WX_GTK_VER="2.8"
MY_P=${P}-2

inherit wxwidgets eutils

DESCRIPTION="XML Copy Editor is a fast, free, validating XML editor"
HOMEPAGE="http://xml-copy-editor.sourceforge.net/"
SRC_URI="mirror://sourceforge/xml-copy-editor/${MY_P}.tar.gz
	guidexml? ( mirror://gentoo/GuideXML-templates.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="aqua guidexml"

RDEPEND=">=dev-libs/libxml2-2.7.3-r1
	dev-libs/libxslt
	dev-libs/xerces-c
	dev-libs/libpcre
	app-text/aspell
	!aqua? ( x11-libs/wxGTK:2.8[X] )
	aqua? ( x11-libs/wxGTK:2.8[aqua] )"
DEPEND="${RDEPEND}
	dev-libs/boost"

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
