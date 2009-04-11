# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/stax-api/stax-api-1.ebuild,v 1.2 2009/03/20 19:56:16 josejx Exp $

EAPI=1

inherit java-virtuals-2

DESCRIPTION="Virtual for Streaming API for XML (StAX)"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
			=virtual/jdk-1.6*
			dev-java/jsr173
		)
		>=dev-java/java-config-2.1.6
		"

JAVA_VIRTUAL_PROVIDES="jsr173"
JAVA_VIRTUAL_VM="icedtea6 sun-jdk-1.6 ibm-jdk-bin-1.6 apple-jdk-bin-1.6"
