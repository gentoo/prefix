# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano/capistrano-2.5.18.ebuild,v 1.2 2010/03/31 15:20:22 flameeyes Exp $

EAPI="2"
USE_RUBY="ruby18"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGELOG README"
RUBY_FAKEGEM_EXTRAINSTALL="VERSION"

inherit ruby-fakegem

DESCRIPTION="A distributed application deployment system"
HOMEPAGE="http://capify.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

ruby_add_rdepend "
	>=dev-ruby/net-ssh-2.0.14
	>=dev-ruby/net-sftp-2.0.2
	>=dev-ruby/net-scp-1.0.2
	>=dev-ruby/net-ssh-gateway-1.0.0
	>=dev-ruby/highline-1.2.7"
ruby_add_bdepend test "dev-ruby/mocha"

RDEPEND="${RDEPEND}
	!dev-ruby/capistrano-launcher"

each_ruby_prepare() {
	# Remove Jeweler check_dependencies task
	sed -i '/check_dependencies/d' Rakefile
}
