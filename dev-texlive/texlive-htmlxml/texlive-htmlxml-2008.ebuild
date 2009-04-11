# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-htmlxml/texlive-htmlxml-2008.ebuild,v 1.10 2009/03/18 20:53:41 ranger Exp $

TEXLIVE_MODULE_CONTENTS="  xmlplay    collection-htmlxml
"
TEXLIVE_MODULE_DOC_CONTENTS="xmlplay.doc "
TEXLIVE_MODULE_SRC_CONTENTS="xmlplay.source "
inherit texlive-module
DESCRIPTION="TeXLive HTML/SGML/XML support"

LICENSE="GPL-2 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
>=dev-texlive/texlive-fontsrecommended-2008
>=dev-texlive/texlive-latex-2008
"
RDEPEND="${DEPEND}"
