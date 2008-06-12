# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-jsch/ant-jsch-1.7.0-r1.ebuild,v 1.5 2007/05/12 18:15:14 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-java/jsch-0.1.21-r2"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack
	cd "${S}"
	epatch "${FILESDIR}/1.7-scp-hang.patch"
}
