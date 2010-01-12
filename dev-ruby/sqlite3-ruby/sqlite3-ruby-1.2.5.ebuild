# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/sqlite3-ruby/sqlite3-ruby-1.2.5.ebuild,v 1.4 2010/01/05 07:36:19 maekke Exp $

EAPI=2
USE_RUBY="ruby18"

RUBY_FAKEGEM_TASK_DOC="docs"
RUBY_FAKEGEM_DOCDIR="doc faq"
RUBY_FAKEGEM_EXTRADOC="README.txt History.txt ChangeLog.cvs"

inherit ruby-fakegem

DESCRIPTION="An extension library to access a SQLite database from Ruby"
HOMEPAGE="http://rubyforge.org/projects/sqlite-ruby/"
LICENSE="BSD"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
SLOT="0"
IUSE=""

RDEPEND="=dev-db/sqlite-3*"
DEPEND="ruby_targets_ruby18? ( dev-lang/swig =dev-db/sqlite-3* )
		ruby_targets_ruby19? ( dev-lang/swig =dev-db/sqlite-3* )"

ruby_add_bdepend "dev-ruby/rake-compiler dev-ruby/hoe"
ruby_add_bdepend test dev-ruby/mocha
ruby_add_bdepend doc dev-ruby/redcloth

all_ruby_prepare() {
	# We remove the vendor_sqlite3 rake task because it's used to
	# bundle SQlite3 which we definitely don't want.
	rm tasks/vendor_sqlite3.rake || die

	sed -i -e 's:, HOE.spec::' tasks/native.rake || die

	rm ext/sqlite3_api/sqlite3_api_wrap.c || die
}

each_ruby_compile() {
	# TODO: not sure what happens with jruby

	# We request the .c file explicitly so that it's rebuilt with
	# swig.
	${RUBY} -S rake ext/sqlite3_api/sqlite3_api_wrap.c compile || die "build failed"
}

all_ruby_compile() {
	all_fakegem_compile

	if use doc; then
		rake faq || die "rake faq failed"
	fi
}

each_ruby_install() {
	each_fakegem_install
}
