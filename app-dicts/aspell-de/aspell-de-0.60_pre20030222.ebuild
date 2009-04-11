# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-dicts/aspell-de/aspell-de-0.60_pre20030222.ebuild,v 1.17 2007/11/03 22:03:00 uberlord Exp $

ASPELL_LANG="German and Swiss-German"
ASPOSTFIX="6"

inherit aspell-dict

LICENSE="GPL-2"

KEYWORDS="~amd64-linux ~x86-linux ~x86-freebsd"

FILENAME=aspell6-de-20030222-1

SRC_URI="mirror://gnu/aspell/dict/de/${FILENAME}.tar.bz2"
S=${WORKDIR}/${FILENAME}
