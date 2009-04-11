# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/plist/plist-3.0.0.ebuild,v 1.1 2007/06/19 01:25:14 nichoj Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A library to manipulate Property List files, also known as plists"
HOMEPAGE="http://plist.rubyforge.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.5"
