# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/xfce4-dev-tools/xfce4-dev-tools-4.7.0.ebuild,v 1.1 2009/08/19 14:17:22 darkside Exp $

EAPI="2"
inherit xfconf

DESCRIPTION="set of scripts and m4/autoconf macros that ease build system maintenance for XFCE"
HOMEPAGE="http://foo-projects.org/~benny/projects/xfce4-dev-tools"
SRC_URI="http://archive.xfce.org/src/xfce/${PN}/4.7/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE=""

DOCS="AUTHORS ChangeLog HACKING NEWS README"
