# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/markaby/markaby-0.5.ebuild,v 1.4 2009/07/12 07:17:32 graaff Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A templating language for Ruby to write HTML templates in pre Ruby"
HOMEPAGE="http://rubyforge.org/projects/markaby/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/builder-2.0.0"
