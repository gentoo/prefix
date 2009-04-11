# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/net-sftp/net-sftp-2.0.1.ebuild,v 1.3 2008/09/21 15:55:14 ranger Exp $

inherit gems

DESCRIPTION="SFTP in pure Ruby"
HOMEPAGE="http://net-ssh.rubyforge.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="=dev-ruby/net-ssh-2*"
