# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Trigger/Class-Trigger-0.14.ebuild,v 1.1 2009/10/12 13:29:42 tove Exp $

EAPI=2

MODULE_AUTHOR=MIYAGAWA
inherit perl-module

DESCRIPTION="Mixin to add / call inheritable triggers"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="dev-perl/IO-stringy"
DEPEND="${RDEPEND}"

SRC_TEST="do"
