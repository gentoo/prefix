# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/builder/builder-2.1.2.ebuild,v 1.1 2007/11/04 07:42:57 graaff Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="A builder to facilitate programatic generation of XML markup"
HOMEPAGE="http://rubyforge.org/projects/builder/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2"
