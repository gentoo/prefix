# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubygems/rubygems-0.9.0-r2.ebuild,v 1.6 2007/02/28 22:07:44 genstef Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="http://rubyforge.org/projects/rubygems/"
LICENSE="Ruby"

# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="http://rubyforge.org/frs/download.php/11289/${P}.tgz"

KEYWORDS="~amd64 ~ppc-macos ~x86"
SLOT="0"
IUSE=""
DEPEND=">=dev-lang/ruby-1.8"

PATCHES="${FILESDIR}/no_post_install.patch
	${FILESDIR}/no-system-rubygems.patch
	${FILESDIR}/${P}-build-c-extensions.patch
	${FILESDIR}/${P}-build-from-yaml.patch"
USE_RUBY="ruby18"

src_compile() {
	return
}

src_install() {
	# RUBYOPT=-rauto_gem without rubygems installed will cause ruby to fail, bug #158455
	export RUBYOPT="${GENTOO_RUBYOPT}"
	ver=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["MAJOR"] + "." + Config::CONFIG["MINOR"]')
	GEM_HOME=${ED}usr/lib/ruby/gems/$ver ruby_src_install
	cp "${FILESDIR}/auto_gem.rb" "${D}"/$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitedir"]')
	keepdir /usr/lib/ruby/gems/$ver/doc
	doenvd "${FILESDIR}/10rubygems"
}

pkg_postinst()
{
	ewarn "If you have previously switched to using ruby18_with_gems using ruby-config, this"
	ewarn "package has removed that file and makes it unnecessary anymore.	Please use ruby-config"
	ewarn "to revert back to ruby18."
}

pkg_postrm()
{
	# If we potentially downgraded, then getting rid of RUBYOPT from env.d is probably a smart idea.
	env-update
	source "${EPREFIX}"/etc/profile
	ewarn "You have removed dev-ruby/rubygems. Ruby applications are unlikely"
	ewarn "to run in current shells because of missing auto_gem."
	ewarn "Please source /etc/profile in your shells before using ruby"
	ewarn "or start new shells"
}
