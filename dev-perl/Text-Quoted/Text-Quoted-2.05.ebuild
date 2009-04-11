# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Quoted/Text-Quoted-2.05.ebuild,v 1.1 2008/07/19 10:48:16 tove Exp $

MODULE_AUTHOR=RUZ
inherit perl-module

DESCRIPTION="Extract the structure of a quoted mail message"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-perl/text-autoformat
	dev-lang/perl"
# Removed: dev-perl/Text-Tabs+Wrap
# # we don't use Text::Tabs anymore as it may segfault on perl 5.8.x with
# # UTF-8 strings and tabs mixed.
# # http://rt.perl.org/rt3/Public/Bug/Display.html?id=40989
# # This bug unlikely to be fixed in 5.8.x, however we use workaround.
# # As soon as Text::Tabs will be fixed we can return back to it

SRC_TEST="do"
