# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-swing/ant-swing-1.7.1.ebuild,v 1.6 2009/04/20 09:58:11 elvanor Exp $

EAPI="2"
DESCRIPTION="Apache Ant's optional tasks for Swing."

# no extra deps
ANT_TASK_DEPNAME=""

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
