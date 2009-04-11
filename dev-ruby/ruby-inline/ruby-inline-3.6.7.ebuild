# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-inline/ruby-inline-3.6.7.ebuild,v 1.1 2008/03/24 22:53:36 rbrown Exp $

inherit gems

MY_P="RubyInline-${PV}"
DESCRIPTION="Allows to embed C/C++ in Ruby code"
HOMEPAGE="http://www.zenspider.com/ZSS/Products/RubyInline/"
SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/hoe-1.3.0"
