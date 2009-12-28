# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/echoe/echoe-4.0-r1.ebuild,v 1.1 2009/12/25 14:39:02 flameeyes Exp $

EAPI=2

USE_RUBY="ruby18 ruby19 jruby"

RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_TASK_DOC="docs"

RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG README TODO"

RUBY_FAKEGEM_EXTRAINSTALL="vendor"

inherit ruby-fakegem

DESCRIPTION="Packaging tool that provides Rake tasks for common operations"
HOMEPAGE="http://blog.evanweaver.com/files/doc/fauna/echoe/files/"

LICENSE="AFL-3.0 MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-solaris"
IUSE=""

ruby_add_rdepend "dev-ruby/highline"

all_ruby_prepare() {
	epatch "${FILESDIR}"/${P}-optional-gemcutter.patch
}
