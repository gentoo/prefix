# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hpricot/hpricot-0.8.2.ebuild,v 1.2 2010/01/13 19:46:13 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18 ruby19 jruby"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG README"

inherit ruby-fakegem

DESCRIPTION="A fast and liberal HTML parser for Ruby."
HOMEPAGE="http://wiki.github.com/why/hpricot"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

# Probably needs the same jdk as JRuby but I'm not sure how to express
# that just yet.
DEPEND="dev-util/ragel
	ruby_targets_jruby? ( >=virtual/jdk-1.5 )"

ruby_add_bdepend dev-ruby/rake
ruby_add_bdepend test virtual/ruby-test-unit

each_ruby_compile() {
	case $(basename ${RUBY}) in
		jruby)
			${RUBY} -S rake compile_java || die "rake compile failed"
			;;
		*)
			${RUBY} -S rake compile || die "rake compile failed"
			;;
	esac
}
