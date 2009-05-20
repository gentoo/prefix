# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/jaf/jaf-1.1.ebuild,v 1.4 2008/10/27 23:25:43 ranger Exp $

EAPI=1

inherit java-virtuals-2

DESCRIPTION="Virtual for JavaBeans Activation Framework (JAF)"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| (
			=virtual/jdk-1.6*
			dev-java/sun-jaf:0
			dev-java/gnu-jaf:1
		)
		>=dev-java/java-config-2.1.6
		"

JAVA_VIRTUAL_PROVIDES="sun-jaf gnu-jaf-1"
JAVA_VIRTUAL_VM="sun-jdk-1.6 ibm-jdk-bin-1.6"
