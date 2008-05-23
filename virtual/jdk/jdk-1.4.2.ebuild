# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jdk/jdk-1.4.2.ebuild,v 1.4 2006/11/09 04:31:53 vapier Exp $

EAPI="prefix"

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="|| (
		=dev-java/apple-jdk-bin-1.4.2*
		=dev-java/blackdown-jdk-1.4.2*
		=dev-java/sun-jdk-1.4.2*
		=dev-java/ibm-jdk-bin-1.4.2*
		=dev-java/jrockit-jdk-bin-1.4.2*
		=dev-java/kaffe-1.1*
	)"
DEPEND=""
