# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/markaby/markaby-0.5.ebuild,v 1.2 2007/10/13 06:01:56 tgall Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A templating language for Ruby to write HTML templates in pre Ruby"
HOMEPAGE="http://rubyforge.org/projects/markaby/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
RESTRICT="test"

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/builder-1.2.0"
