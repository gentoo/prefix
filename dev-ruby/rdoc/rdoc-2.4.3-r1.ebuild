# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rdoc/rdoc-2.4.3-r1.ebuild,v 1.6 2010/01/30 18:30:00 armin76 Exp $

EAPI=2
USE_RUBY="ruby18 ruby19 jruby"

RUBY_FAKEGEM_TASK_DOC="docs"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="History.txt Manifest.txt README.txt RI.txt"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem

DESCRIPTION="An extended version of the RDoc library from Ruby 1.8"
HOMEPAGE="http://rubyforge.org/projects/rdoc/"
SRC_URI="mirror://rubyforge/${PN}/${P}.tgz"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-solaris"
IUSE=""

ruby_add_bdepend test dev-ruby/hoe
ruby_add_bdepend test virtual/ruby-minitest
ruby_add_bdepend doc dev-ruby/hoe

all_ruby_install() {
	all_fakegem_install

	for bin in rdoc ri; do
		ruby_fakegem_binwrapper $bin /usr/bin/$bin-2
	done
}

each_ruby_test() {
	# `rake test' would fail when rdoc is not yet installed.
	# Setting $rdoc_rakefile fixes this.
	${RUBY} -w -Ilib:ext:bin:test \
		-e 'require "rubygems"; require	"minitest/autorun"; \
		$rdoc_rakefile = true; Dir.glob("test/test*.rb").each \
		{|t| require t }' || die "Tests failed for ${RUBY}"
}
