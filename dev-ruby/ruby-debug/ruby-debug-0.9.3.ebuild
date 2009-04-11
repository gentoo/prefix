# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-debug/ruby-debug-0.9.3.ebuild,v 1.1 2007/08/04 11:51:07 graaff Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="CLI interface to ruby-debug"
HOMEPAGE="http://rubyforge.org/projects/ruby-debug/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="ruby-debug"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

DEPEND="=dev-ruby/ruby-debug-base-0.9.3
	>=dev-lang/ruby-1.8.4"
RDEPEND="${DEPEND}"
