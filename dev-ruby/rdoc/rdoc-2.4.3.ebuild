# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rdoc/rdoc-2.4.3.ebuild,v 1.3 2009/12/25 17:21:10 flameeyes Exp $

EAPI=2
USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_TASK_DOC="doc"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="History.txt Manifest.txt README.txt RI.txt"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem

DESCRIPTION="An extended version of the RDoc library from Ruby 1.8"
HOMEPAGE="http://rubyforge.org/projects/${PN}/"
SRC_URI="mirror://rubyforge/${PN}/${P}.tgz"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-solaris"
IUSE=""

ruby_add_bdepend test dev-ruby/hoe
ruby_add_bdepend doc dev-ruby/hoe

all_ruby_install() {
	all_fakegem_install

	for bin in rdoc ri; do
		ruby_fakegem_binwrapper $bin $bin-2
	done
}
