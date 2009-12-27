# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/sexp-processor/sexp-processor-3.0.3-r1.ebuild,v 1.1 2009/12/25 21:06:28 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_NAME="sexp_processor"

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.txt History.txt"

inherit ruby-fakegem

DESCRIPTION="Processor for s-expressions created as part of the ParseTree project."
HOMEPAGE="http://www.zenspider.com/ZSS/Products/ParseTree/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

ruby_add_bdepend test "dev-ruby/hoe dev-ruby/hoe-seattlerb virtual/ruby-minitest"
ruby_add_bdepend doc "dev-ruby/hoe dev-ruby/hoe-seattlerb"
