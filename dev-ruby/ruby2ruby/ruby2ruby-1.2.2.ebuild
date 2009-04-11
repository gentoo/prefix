# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby2ruby/ruby2ruby-1.2.2.ebuild,v 1.1 2009/03/06 06:55:11 graaff Exp $

inherit gems

DESCRIPTION="Generates readable ruby from ParseTree"
HOMEPAGE="http://seattlerb.rubyforge.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/parsetree-3.0
		>=dev-ruby/hoe-1.8.2"

USE_RUBY="ruby18 ruby19"
