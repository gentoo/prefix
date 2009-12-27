# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/parsetree/parsetree-3.0.4-r1.ebuild,v 1.1 2009/12/26 17:49:58 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18"

RUBY_FAKEGEM_NAME="ParseTree"

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.txt History.txt"

inherit ruby-fakegem

DESCRIPTION="ParseTree extracts the parse tree for a Class or method and returns it as a s-expression."
HOMEPAGE="http://www.zenspider.com/ZSS/Products/ParseTree/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

ruby_add_rdepend '>=dev-ruby/ruby-inline-3.7.0 >=dev-ruby/sexp-processor-3.0.0'
ruby_add_bdepend test "dev-ruby/hoe dev-ruby/hoe-seattlerb virtual/ruby-minitest dev-ruby/ruby2ruby"
ruby_add_bdepend doc "dev-ruby/hoe dev-ruby/hoe-seattlerb"

src_test() {
	chmod 0755 ${WORKDIR/work/homedir} || die "Failed to fix permissions on home"

	ruby-ng_src_test
}
