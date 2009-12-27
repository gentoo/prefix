# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/zentest/zentest-4.2.1.ebuild,v 1.1 2009/12/25 18:48:23 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_NAME=ZenTest

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.txt History.txt"

inherit ruby-fakegem

DESCRIPTION="ZenTest provides tools to support testing: zentest, unit_diff, autotest, multiruby, and Test::Rails"
HOMEPAGE="http://rubyforge.org/projects/zentest/"
LICENSE="Ruby"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

ruby_add_bdepend doc 'dev-ruby/hoe dev-ruby/hoe-seattlerb'
ruby_add_bdepend test 'dev-ruby/hoe dev-ruby/hoe-seattlerb virtual/ruby-minitest'

pkg_postinst() {
	ewarn "Since 4.1.1 ZenTest no longer bundles support to run autotest Rails projects."
	ewarn "Please install dev-ruby/autotest-rails to add Rails support to autotest."
}
