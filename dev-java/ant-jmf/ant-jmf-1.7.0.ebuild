# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-jmf/ant-jmf-1.7.0.ebuild,v 1.10 2007/05/12 18:14:20 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

src_unpack() {
	# seems no need to dep on jmf-bin, the classes ant imports are in J2SE API since 1.3
	ant-tasks_src_unpack base
}
