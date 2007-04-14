# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/activesupport/activesupport-1.4.2.ebuild,v 1.1 2007/03/14 04:20:08 nichoj Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="Utility Classes and Extension to the Standard Library"
HOMEPAGE="http://rubyforge.org/projects/activesupport/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="1.2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.5
	>=dev-ruby/rubygems-0.9.0"
