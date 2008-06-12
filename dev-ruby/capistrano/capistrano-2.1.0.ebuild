# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano/capistrano-2.1.0.ebuild,v 1.2 2007/12/10 16:58:33 armin76 Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="A distributed application deployment system"
HOMEPAGE="http://capify.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/rake-0.7.0
	>=dev-ruby/net-ssh-1.0.10
	>=dev-ruby/net-sftp-1.1.0
	>=dev-ruby/highline-1.2.7"
PDEPEND="dev-ruby/capistrano-launcher"

src_install() {
	gems_src_install

	# Deleted cap, as it will be provided by capistrano-launcher
	rm "${ED}/usr/bin/cap"
	rm "${ED}/${GEMSDIR}/bin/cap"
}
