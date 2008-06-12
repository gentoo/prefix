# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano/capistrano-1.4.1-r1.ebuild,v 1.5 2008/04/09 22:07:09 robbat2 Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="A distributed application deployment system"
HOMEPAGE="http://rubyforge.org/projects/capistrano/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/rake-0.7.0
	>=dev-ruby/net-ssh-1.0.10
	>=dev-ruby/net-sftp-1.1.0"
PDEPEND="dev-ruby/capistrano-launcher"

src_install() {
	gems_src_install

	# Deleted cap, as it will be provided by capistrano-launcher
	rm "${ED}/usr/bin/cap"
	rm "${ED}/${GEMSDIR}/bin/cap"
}
