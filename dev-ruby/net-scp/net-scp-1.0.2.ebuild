# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/net-scp/net-scp-1.0.2.ebuild,v 1.3 2009/04/05 14:15:02 maekke Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="A pure Ruby implementation of the SCP client protocol"
HOMEPAGE="http://net-ssh.rubyforge.org/scp"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-ruby/net-ssh-2.0.0"
