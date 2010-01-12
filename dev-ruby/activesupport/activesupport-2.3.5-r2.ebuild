# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/activesupport/activesupport-2.3.5-r2.ebuild,v 1.2 2010/01/04 10:50:11 fauli Exp $

EAPI=2
USE_RUBY="ruby18"

RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_TASK_DOC=""

RUBY_FAKEGEM_EXTRADOC="CHANGELOG README"

inherit ruby-fakegem

DESCRIPTION="Utility Classes and Extension to the Standard Library"
HOMEPAGE="http://rubyforge.org/projects/activesupport/"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

ruby_add_rdepend ">=dev-ruby/builder-2.1.2 >=dev-ruby/tzinfo-0.3.12 dev-ruby/i18n"

all_ruby_prepare() {
	# Remove the bundled packages!
	rm -r lib/active_support/vendor/{tzinfo,builder,i18n}-* \
		|| die "failed to remove vendor packages"
}
