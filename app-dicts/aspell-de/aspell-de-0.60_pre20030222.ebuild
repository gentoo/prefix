# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/aspell-de/aspell-de-0.60_pre20030222.ebuild,v 1.18 2009/10/18 20:13:20 halcy0n Exp $

ASPELL_LANG="German and Swiss-German"
ASPOSTFIX="6"

inherit aspell-dict

LICENSE="GPL-2"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos"
IUSE=""

FILENAME=aspell6-de-20030222-1

SRC_URI="mirror://gnu/aspell/dict/de/${FILENAME}.tar.bz2"
S=${WORKDIR}/${FILENAME}
