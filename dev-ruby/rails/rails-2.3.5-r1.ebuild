# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rails/rails-2.3.5-r1.ebuild,v 1.4 2010/02/01 21:15:10 maekke Exp $

EAPI=2
USE_RUBY="ruby18"

RUBY_FAKEGEM_EXTRAINSTALL="builtin configs dispatches environments helpers html"
RUBY_FAKEGEM_EXTRADOC="README CHANGELOG"

RUBY_FAKEGEM_BINWRAP=""

# gem lacks tests
RUBY_FAKEGEM_TASK_TEST=""

inherit ruby-fakegem

DESCRIPTION="ruby on rails is a web-application and persistance framework"
HOMEPAGE="http://www.rubyonrails.org"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

IUSE=""

RDEPEND=">=app-admin/eselect-rails-0.15"

ruby_add_rdepend ">=dev-ruby/rake-0.8.3
	~dev-ruby/activerecord-${PV}
	~dev-ruby/activeresource-${PV}
	~dev-ruby/activesupport-${PV}
	~dev-ruby/actionmailer-${PV}
	~dev-ruby/actionpack-${PV}"
ruby_add_bdepend doc dev-ruby/redcloth
ruby_add_bdepend test dev-ruby/mocha

all_ruby_prepare() {
	sed -i -e '/horo/d' Rakefile || die
}

all_ruby_compile() {
	all_fakegem_compile

	# fails for missing template when using the gem distribution
	#if use doc; then
	#	pushd guides
	#	ruby rails_guides.rb || die "guide generation failed"
	#	popd
	#fi
}
all_ruby_install() {
	all_fakegem_install

	ruby_fakegem_binwrapper rails rails-${PV}

	if use doc; then
		#pushd guides/output
		#docinto guides
		#dohtml -r *
		#popd

		pushd doc
		docinto api
		dohtml -r *
		popd
	fi
}

pkg_postinst() {
	elog "To select between slots of rails, use:"
	elog "\teselect rails"

	eselect rails update
}

pkg_postrm() {
	eselect rails update
}
