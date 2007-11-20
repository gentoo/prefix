# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-nodeps/ant-nodeps-1.7.0.ebuild,v 1.11 2007/08/21 12:50:18 opfer Exp $

EAPI="prefix"

inherit ant-tasks

DESCRIPTION="Apache Ant's optional tasks requiring no external deps"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"

src_unpack() {
	ant-tasks_src_unpack base
	java-pkg_jar-from --build-only ant-core ant-launcher.jar
	java-pkg_filter-compiler jikes
}

src_compile() {
	eant jar-nodeps
}
