# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/sexp-processor/sexp-processor-3.0.0.ebuild,v 1.1 2008/12/28 09:34:23 graaff Exp $

inherit gems

MY_PN="sexp_processor"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Processor for s-expressions created as part of the ParseTree project."
HOMEPAGE="http://www.zenspider.com/ZSS/Products/ParseTree/"
SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ppc-macos ~x86-linux ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/hoe-1.8.0"

USE_RUBY="ruby18 ruby19"
