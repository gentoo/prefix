# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jre/jre-1.4.2.ebuild,v 1.4 2006/11/27 00:17:10 vapier Exp $

EAPI="prefix"

DESCRIPTION="Virtual for JRE"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="|| (
		=virtual/jdk-1.4.2*
		=dev-java/blackdown-jre-1.4.2*
		=dev-java/kaffe-1.1*
		=dev-java/sun-jre-bin-1.4.2*
		=dev-java/ibm-jre-bin-1.4.2*
	)"
DEPEND=""
