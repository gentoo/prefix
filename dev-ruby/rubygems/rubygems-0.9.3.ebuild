# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubygems/rubygems-0.9.3.ebuild,v 1.1 2007/05/17 08:54:15 rbrown Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="http://rubyforge.org/projects/rubygems/"
LICENSE="Ruby"

# Needs to be installed first
RESTRICT="test"

# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="http://rubyforge.org/frs/download.php/20585/${P}.tgz"

KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
SLOT="0"
IUSE="doc server examples"
PDEPEND="server? ( dev-ruby/builder )" # index_gem_repository.rb

PATCHES="${FILESDIR}/${PN}-0.9.1-no_post_install.patch
	${FILESDIR}/no-system-rubygems.patch"
USE_RUBY="ruby18"

src_unpack() {
	ruby_src_unpack
	use doc || epatch "${FILESDIR}/${PN}-0.9.1-no_rdoc_install.patch"

	# Delete mis-packaged . files
	cd ${S}
	find -name '.*' -type f -print0|xargs -0 rm
}

src_compile() {
	${RUBY} setup.rb config --libruby="/usr/$(get_libdir)/ruby" || die "setup.rb config failed"
	${RUBY} setup.rb setup || die "setup.rb setup failed"
}

src_test() {
	# Currently RESTRICTed because rubygems needs to be installed
	# When I work out how to get around that I'll remove the RETRICT

	#for i in test/{test,functional}*.rb; do
	#	ruby -I pkgs/sources/lib/ -I lib ${i} # || die "$i failed"
	#done
	ruby setup.rb test || die "test failed"
}

src_install() {
	# RUBYOPT=-rauto_gem without rubygems installed will cause ruby to fail, bug #158455
	export RUBYOPT="${GENTOO_RUBYOPT}"

	# Fix GEM_HOME to install sources.gem
	ver=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["ruby_version"]')
	export GEM_HOME="${ED}usr/$(get_libdir)/ruby/gems/${ver}"

	${RUBY} setup.rb install --prefix=${D} || die "setup.rb install failed"
	erubydoc
	cp "${FILESDIR}/auto_gem.rb" "${D}"/$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]')
	keepdir /usr/$(get_libdir)/ruby/gems/$ver/doc
	doenvd "${FILESDIR}/10rubygems"
}

pkg_postinst()
{
	ewarn "If you have previously switched to using ruby18_with_gems using ruby-config, this"
	ewarn "package has removed that file and makes it unnecessary anymore."
	ewarn "Please use ruby-config to revert back to ruby18."
}

pkg_postrm()
{
	ewarn "If you have uninstalled dev-ruby/rubygems. Ruby applications are unlikely"
	ewarn "to run in current shells because of missing auto_gem."
	ewarn "Please run \"unset RUBYOPT\" in your shells before using ruby"
	ewarn "or start new shells"
	ewarn
	ewarn "If you have not unstinalled dev-ruby/rubygems, please do not unset "
	ewarn "RUBYOPT"
}
