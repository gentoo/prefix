# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/racc/racc-1.4.6.ebuild,v 1.1 2009/12/25 18:06:28 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.en.rdoc README.ja.rdoc TODO ChangeLog"

inherit ruby-fakegem

DESCRIPTION="A LALR(1) parser generator for Ruby"
HOMEPAGE="http://www.loveruby.net/en/racc.html"

LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

ruby_add_bdepend test virtual/ruby-test-unit

all_ruby_prepare() {
	sed -i -e '/tasks\/email/s:^:#:' Rakefile || die "rakefile fix failed"
	sed -i -e '/prerequisites/s:^:#:' tasks/test.rb || die "test task fix failed"
	sed -i -e 's|/tmp/out|${TMPDIR:-/tmp}/out|' test/helper.rb || die "tests fix failed"
}

each_ruby_prepare() {
	if [[ $(basename ${RUBY}) == "ruby18" ]]; then
		sed -i -e 's:ruby/ruby.h:ruby.h:' \
			ext/racc/cparse/cparse.c || die
	fi
}

each_ruby_compile() {
	${RUBY} -S rake build || die "build failed"
}

each_ruby_install() {
	each_fakegem_install
	ruby_fakegem_newins ext/racc/cparse/cparse.so lib/racc/cparse.so
}

all_ruby_install() {
	all_fakegem_install

	docinto examples
	dodoc sample/* || die
}
