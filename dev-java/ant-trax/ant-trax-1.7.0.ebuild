# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-trax/ant-trax-1.7.0.ebuild,v 1.10 2007/05/12 18:19:06 wltjr Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="xalan"

inherit ant-tasks

DESCRIPTION="Apache Ant .jar with optional tasks depending on XML transformer (xalan)"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

# it will build without it (ant manual says it's not needed since 1.4 JDK, dunno bout kaffe
# but contains a Xalan2Executor task which probably wouldn't work
DEPEND=">=dev-java/xalan-2.7.0-r2
	~dev-java/ant-junit-${PV}"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack all
	java-pkg_jar-from ant-junit
}
