# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Manifest/Test-Manifest-1.23.ebuild,v 1.1 2009/07/18 08:23:11 tove Exp $

EAPI=2

MODULE_AUTHOR=BDFOY
inherit perl-module

DESCRIPTION="Interact with a t/test_manifest file"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND=""
DEPEND="test? ( dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

SRC_TEST="do"
