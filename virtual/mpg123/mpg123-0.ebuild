# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mpg123/mpg123-0.ebuild,v 1.5 2009/06/21 07:44:13 ssuominen Exp $

EAPI=2

DESCRIPTION="Virtual for command-line players mpg123 and mpg321"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="|| ( >=media-sound/mpg123-1.7.3-r1
	>=media-sound/mpg321-0.2.10-r4[symlink] )"
DEPEND="${RDEPEND}"
