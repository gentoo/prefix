# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano/capistrano-1.4.1.ebuild,v 1.6 2007/04/16 08:50:14 opfer Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A distributed application deployment system"
HOMEPAGE="http://rubyforge.org/projects/capistrano/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""
#RESTRICT="test"

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/rake-0.7.0
	>=dev-ruby/net-ssh-1.0.10
	>=dev-ruby/net-sftp-1.1.0"

pkg_postinst()
{
	elog
	elog "Capistrano has replaced switchtower due to naming issues.  If you were previously using"
	elog "switchtower in your Rails apps, you need to manually remove lib/tasks/switchtower.rake"
	elog "from them and then run 'cap -A .' in your project directory, making sure to keep deploy.rb"
	elog
}
