# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby_parser/ruby_parser-2.0.4-r1.ebuild,v 1.1 2009/12/26 17:48:29 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18"

# Don't run tests, since they require the testcase from ParseTree;
# ParseTree _is_ the testcase for ruby_parse
RUBY_FAKEGEM_TASK_TEST=""

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="README.txt History.txt"

inherit ruby-fakegem

DESCRIPTION="A ruby parser written in pure ruby."
HOMEPAGE="http://parsetree.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-solaris"
IUSE=""

ruby_add_rdepend ">=dev-ruby/sexp-processor-3.0.1"
