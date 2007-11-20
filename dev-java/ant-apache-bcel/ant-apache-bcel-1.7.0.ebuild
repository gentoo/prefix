# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-apache-bcel/ant-apache-bcel-1.7.0.ebuild,v 1.10 2007/05/12 17:51:21 wltjr Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="bcel"

inherit ant-tasks

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"

DEPEND="~dev-java/ant-nodeps-${PV}
	>=dev-java/bcel-5.1-r3"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack all
	java-pkg_jar-from ant-nodeps
}
