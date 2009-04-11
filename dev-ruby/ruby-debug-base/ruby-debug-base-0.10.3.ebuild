# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-debug-base/ruby-debug-base-0.10.3.ebuild,v 1.2 2009/03/20 05:08:58 josejx Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="Fast Ruby debugger"
HOMEPAGE="http://rubyforge.org/projects/ruby-debug/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="ruby-debug"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.4
	>=dev-ruby/linecache-0.3"
RDEPEND="${DEPEND}"
