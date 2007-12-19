# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-fontsrecommended/texlive-fontsrecommended-2007.ebuild,v 1.7 2007/12/18 19:43:56 jer Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
!dev-tex/eurosym"
TEXLIVE_MODULE_CONTENTS="adobeuro avantgar bookman charter cmextra courier euro euro-ce eurofont eurosans eurosym fpl helvetic marvosym mathpazo ncntrsbk palatino psnfssx pxfonts rsfs symbol tex-gyre times timesnew tipa txfonts utopia wasy wasysym zapfchan zapfding collection-fontsrecommended
"
inherit texlive-module
DESCRIPTION="TeXLive Recommended fonts"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
