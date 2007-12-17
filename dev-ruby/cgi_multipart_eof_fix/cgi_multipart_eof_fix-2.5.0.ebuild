# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/cgi_multipart_eof_fix/cgi_multipart_eof_fix-2.5.0.ebuild,v 1.1 2007/12/16 02:33:11 nichoj Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="Fix an exploitable bug in CGI multipart parsing."
HOMEPAGE="http://rubyforge.org/projects/mongrel/"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""
