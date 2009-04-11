# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/javamail/javamail-1.0-r1.ebuild,v 1.8 2008/03/12 15:15:58 armin76 Exp $

inherit java-virtuals-2

DESCRIPTION="Virtual for javamail implementations"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| ( dev-java/sun-javamail >=dev-java/gnu-javamail-1.0-r2 )
		!<dev-java/gnu-javamail-1.0-r2"

JAVA_VIRTUAL_PROVIDES="sun-javamail gnu-javamail-1"
