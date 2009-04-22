# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-jmf/ant-jmf-1.7.1.ebuild,v 1.7 2009/04/20 09:57:32 elvanor Exp $

EAPI="2"
DESCRIPTION="Apache Ant's optional tasks for the Java Media Framework (JMF)."

# seems no need to dep on jmf-bin, the classes ant imports are in J2SE API since 1.3
ANT_TASK_DEPNAME=""

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
