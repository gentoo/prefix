# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jdk/jdk-1.6.0.ebuild,v 1.6 2008/01/18 01:41:42 ranger Exp $

EAPI="prefix"

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.6"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="|| (
		=dev-java/soylatte-jdk-bin-1.0*
		=dev-java/apple-jdk-bin-1.6.0*
		=dev-java/sun-jdk-1.6.0*
		=dev-java/ibm-jdk-bin-1.6.0*
	)"
DEPEND=""
