# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-htmlxml/texlive-htmlxml-2008.ebuild,v 1.1 2008/09/09 16:29:41 aballier Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
dev-texlive/texlive-fontsrecommended
dev-texlive/texlive-latex
"
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
