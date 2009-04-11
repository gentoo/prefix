# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-javamail/ant-javamail-1.7.0-r1.ebuild,v 1.2 2008/04/27 11:07:47 caster Exp $

ANT_TASK_DEPNAME="--virtual javamail"

inherit ant-tasks

DESCRIPTION="Apache Ant's optional tasks for javamail"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND="java-virtuals/javamail
	>=dev-java/sun-jaf-1.1"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack all
	java-pkg_jar-from sun-jaf
}
