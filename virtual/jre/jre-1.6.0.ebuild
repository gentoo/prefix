# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jre/jre-1.6.0.ebuild,v 1.4 2007/12/16 13:59:53 caster Exp $

EAPI="prefix"

DESCRIPTION="Virtual for JRE"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.6"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

RDEPEND="|| (
		=virtual/jdk-1.6.0*
		=dev-java/sun-jre-bin-1.6.0*
		=dev-java/ibm-jre-bin-1.6.0*
	)"
DEPEND=""
