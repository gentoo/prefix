# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jdk/jdk-1.6.0.ebuild,v 1.4 2007/12/16 11:12:06 caster Exp $

EAPI="prefix"

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.6"
KEYWORDS="~amd64 ~ia64 ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

RDEPEND="|| (
		=dev-java/apple-jdk-bin-1.6.0*
		=dev-java/sun-jdk-1.6.0*
		=dev-java/ibm-jdk-bin-1.6.0*
	)"
DEPEND=""
