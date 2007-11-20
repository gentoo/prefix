# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-swing/ant-swing-1.7.0.ebuild,v 1.10 2007/05/12 18:20:36 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd"

src_unpack() {
	ant-tasks_src_unpack base
}
