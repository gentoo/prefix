# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rake-compiler/rake-compiler-0.7.0-r1.ebuild,v 1.1 2010/01/28 12:03:14 flameeyes Exp $

EAPI=2
USE_RUBY="ruby18 ruby19 jruby"

# Tests for now seem only to work when rubygems is fully installed for
# the implementation and that for now only means Ruby 1.8
RUBY_FAKEGEM_TASK_TEST="spec cucumber"

RUBY_FAKEGEM_DOCDIR="doc/api"
RUBY_FAKEGEM_EXTRADOC="History.txt README.rdoc"

inherit ruby-fakegem eutils

DESCRIPTION="Provide a standard and simplified way to build and package Ruby extensions"
HOMEPAGE="http://github.com/luislavena/rake-compiler"
LICENSE="as-is" # truly

SRC_URI="http://github.com/luislavena/${PN}/tarball/v${PV} -> ${P}.tar.gz"
S="${WORKDIR}/luislavena-${PN}-2834041"

KEYWORDS="~amd64-linux ~x86-solaris"
SLOT="0"
IUSE=""

ruby_add_bdepend doc ">=dev-ruby/rdoc-2.4.3"

USE_RUBY=ruby18 \
	ruby_add_bdepend "test ruby_targets_ruby18" "dev-ruby/rspec dev-util/cucumber dev-ruby/rubygems"

all_ruby_prepare() {
	epatch "${FILESDIR}"/${P}+ruby-1.8.7.patch
}

each_ruby_prepare() {
	case ${RUBY} in
		*ruby19|*jruby)
			# Remove this task so that it won't load on Ruby 1.9 and JRuby
			# that lack the package_task file. It is, though, needed for the
			# tests
			rm tasks/gem.rake || die
			;;
		*)
			;;
	esac
}

each_ruby_test() {
	case ${RUBY} in
		*ruby19|*jruby)
			ewarn "Tests disabled for this implementation. Long story, check ebuild if you want."
			;;
		*)
			each_fakegem_test
			;;
	esac
}
