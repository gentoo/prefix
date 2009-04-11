# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/zentest/zentest-4.0.0.ebuild,v 1.1 2009/03/06 12:16:10 graaff Exp $

inherit gems

MY_P=${P/zentest/ZenTest}
S=${WORKDIR}/${MY_P}

DESCRIPTION="ZenTest provides tools to support testing: zentest, unit_diff, autotest, multiruby, and Test::Rails"
HOMEPAGE="http://rubyforge.org/projects/zentest/"
LICENSE="Ruby"

SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

DEPEND=">=dev-ruby/rubygems-1.3.0"
