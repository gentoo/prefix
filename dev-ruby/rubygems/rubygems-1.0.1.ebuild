# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubygems/rubygems-1.0.1.ebuild,v 1.3 2008/01/13 07:12:34 redhatter Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="http://rubyforge.org/projects/rubygems/"
LICENSE="Ruby"

# Needs to be installed first
RESTRICT="test"

# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="http://rubyforge.org/frs/download.php/29548/${P}.tgz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
SLOT="0"
IUSE="doc server examples"
PDEPEND="server? ( dev-ruby/builder )" # index_gem_repository.rb

USE_RUBY="ruby18"

PATCHES="${FILESDIR}/${PN}-0.9.5-setup.patch"

src_unpack() {
	ruby_src_unpack

	# Delete mis-packaged . files
	cd "${S}"
	find -name '.*' -type f -print0|xargs -0 rm

}

src_compile() {
	# Allowing ruby_src_compile would be bad with the new setup.rb
	:
}

src_install() {
	# RUBYOPT=-rauto_gem without rubygems installed will cause ruby to fail, bug #158455
	export RUBYOPT="${GENTOO_RUBYOPT}"

	ver=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["ruby_version"]')
	export GEM_HOME="${EPREFIX}/usr/$(get_libdir)/ruby/gems/${ver}"
	keepdir /usr/$(get_libdir)/ruby/gems/$ver/{doc,gems,cache,specifications}

	myconf="--no-ri"
	if ! use doc; then
		myconf="${myconf} --no-rdoc"
	fi

	${RUBY} setup.rb $myconf --prefix="${D}" || die "setup.rb install failed"

	dosym /usr/bin/gem18 /usr/bin/gem
	dosym /usr/bin/update_rubygems18 /usr/bin/update_rubygems

	dodoc README
	if use examples; then
		cp -pPR examples "${ED}/usr/share/doc/${PF}"
	fi

	cp "${FILESDIR}/auto_gem.rb" "${D}"/$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]')
	keepdir /usr/$(get_libdir)/ruby/gems/$ver/doc
	doenvd "${FILESDIR}/10rubygems"

	if use server; then
		newinitd "${FILESDIR}/init.d-gem_server" gem_server
		newconfd "${FILESDIR}/conf.d-gem_server" gem_server
	fi
}

pkg_postinst()
{
	ver=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["ruby_version"]')
	SOURCE_CACHE="/usr/$(get_libdir)/ruby/gems/$ver/source_cache"
	if [[ -e "${SOURCE_CACHE}" ]]; then
		rm "${SOURCE_CACHE}"
	fi

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
	ewarn "If you have not uninstalled dev-ruby/rubygems, please do not unset "
	ewarn "RUBYOPT"
}
