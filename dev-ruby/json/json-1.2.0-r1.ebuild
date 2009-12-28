# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/json/json-1.2.0-r1.ebuild,v 1.6 2009/12/26 21:32:58 flameeyes Exp $

EAPI=2
USE_RUBY="ruby18 ruby19 jruby"

RUBY_FAKEGEM_TASK_DOC="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGES TODO README"
RUBY_FAKEGEM_DOCDIR="doc"

inherit ruby-fakegem

DESCRIPTION="A JSON implementation as a Ruby extension."
HOMEPAGE="http://json.rubyforge.org/"
LICENSE="|| ( Ruby GPL-2 )"
SRC_URI="mirror://rubygems/${P}.gem"

KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="dev-util/ragel"

ruby_add_bdepend test virtual/ruby-test-unit

all_ruby_prepare() {
	# Avoid building the extension twice!
	sed -i \
		-e 's| => :compile_ext||' \
		-e 's| => :clean||' \
		Rakefile || die "rakefile fix failed"
}

each_ruby_compile() {
	if [[ $(basename ${RUBY}) != "jruby" ]]; then
		${RUBY} -S rake compile_ext || die "extension compile failed"
	fi
}

each_ruby_test() {
	# We have to set RUBYLIB because otherwise the tests will run
	# against the sytem-installed json; at the same time, we cannot
	# use the -I parameter because rake won't let it pass to the
	# testrb call that is executed down the road.

	RUBYLIB="${RUBYLIB}${RUBYLIB+:}lib:ext/json/ext" \
		${RUBY} -S rake test_pure || die "pure ruby tests failed"

	if [[ $(basename ${RUBY}) != "jruby" ]]; then
		RUBYLIB="${RUBYLIB}${RUBYLIB+:}lib:ext/json/ext" \
			${RUBY} -Ilib:ext/json/ext -S rake test_ext || die " ruby extension tests failed"
	fi
}

each_ruby_install() {
	each_fakegem_install
	if [[ $(basename ${RUBY}) != "jruby" ]]; then
		ruby_fakegem_newins ext/json/ext/generator.so lib/json/generator.so
		ruby_fakegem_newins ext/json/ext/parser.so lib/json/parser.so
	fi
}
