# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/net-sftp/net-sftp-2.0.2.ebuild,v 1.5 2009/04/10 14:38:32 armin76 Exp $

inherit gems

DESCRIPTION="SFTP in pure Ruby"
HOMEPAGE="http://net-ssh.rubyforge.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=dev-ruby/net-ssh-2.0.9"
DEPEND="${RDEPEND}"
