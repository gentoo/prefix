# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-fontsrecommended/texlive-fontsrecommended-2008.ebuild,v 1.11 2009/03/18 20:59:10 ranger Exp $

TEXLIVE_MODULE_CONTENTS="avantgar bookman charter cmextra courier euro euro-ce eurofont eurosans eurosym fpl helvetic lm marvosym mathpazo ncntrsbk palatino pxfonts rsfs symbol tex-gyre times timesnew tipa txfonts utopia wasy wasysym zapfchan zapfding collection-fontsrecommended
"
TEXLIVE_MODULE_DOC_CONTENTS="charter.doc euro.doc euro-ce.doc eurofont.doc eurosans.doc eurosym.doc fpl.doc lm.doc marvosym.doc mathpazo.doc pxfonts.doc rsfs.doc tex-gyre.doc tipa.doc txfonts.doc utopia.doc wasy.doc wasysym.doc "
TEXLIVE_MODULE_SRC_CONTENTS="euro.source eurofont.source eurosym.source fpl.source lm.source mathpazo.source wasysym.source "
inherit texlive-module
DESCRIPTION="TeXLive Recommended fonts"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
!=dev-texlive/texlive-basic-2007*
"
RDEPEND="${DEPEND}"
