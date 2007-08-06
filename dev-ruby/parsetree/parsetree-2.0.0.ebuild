# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/parsetree/parsetree-2.0.0.ebuild,v 1.2 2007/08/05 16:02:00 mr_bones_ Exp $

EAPI="prefix"

inherit ruby gems

MY_PN="ParseTree"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="ParseTree is a C extension (using RubyInline) returns the as a s-expression."
HOMEPAGE="http://www.zenspider.com/ZSS/Products/ParseTree/"
SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"
DEPEND=">=dev-lang/ruby-1.8.4
		>=dev-ruby/ruby-inline-3.6.0
		>=dev-ruby/hoe-1.2.2"
