# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MP3-Tag/MP3-Tag-1.11.ebuild,v 1.1 2009/05/11 10:35:38 tove Exp $

EAPI=2

MODULE_AUTHOR=ILYAZ
MODULE_SECTION=modules
inherit perl-module eutils

DESCRIPTION="Tag - Module for reading tags of mp3 files"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

SRC_TEST="do"
