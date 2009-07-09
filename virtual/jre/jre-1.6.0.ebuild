# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jre/jre-1.6.0.ebuild,v 1.9 2009/07/05 05:11:05 ali_bush Exp $

DESCRIPTION="Virtual for JRE"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.6"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="|| (
		=virtual/jdk-1.6.0*
		=dev-java/sun-jre-bin-1.6.0*
		=dev-java/ibm-jre-bin-1.6.0*
		=dev-java/diablo-jre-bin-1.6.0*
	)"
DEPEND=""
