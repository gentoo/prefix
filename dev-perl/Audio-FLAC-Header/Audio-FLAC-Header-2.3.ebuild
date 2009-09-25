# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Audio-FLAC-Header/Audio-FLAC-Header-2.3.ebuild,v 1.1 2008/11/21 11:06:17 tove Exp $

MODULE_AUTHOR=DANIEL
inherit perl-module

DESCRIPTION="Access to FLAC audio metadata"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

DEPEND="media-libs/flac
	dev-lang/perl"

SRC_TEST="do"
