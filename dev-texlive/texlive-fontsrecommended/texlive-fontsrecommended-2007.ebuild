# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-fontsrecommended/texlive-fontsrecommended-2007.ebuild,v 1.15 2008/05/12 19:22:00 nixnut Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
!dev-tex/eurosym"
TEXLIVE_MODULE_CONTENTS="adobeuro avantgar bookman charter cmextra courier euro euro-ce eurofont eurosans eurosym fpl helvetic marvosym mathpazo ncntrsbk palatino psnfssx pxfonts rsfs symbol tex-gyre times timesnew tipa txfonts utopia wasy wasysym zapfchan zapfding collection-fontsrecommended
"
inherit texlive-module
DESCRIPTION="TeXLive Recommended fonts"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
