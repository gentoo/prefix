# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-dev-tools/xfce4-dev-tools-4.4.0.ebuild,v 1.13 2007/05/27 06:37:49 kumba Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="m4macros for autotools eclass and subversion builds"
HOMEPAGE="http://foo-projects.org/~benny/projects/xfce4-dev-tools"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"

RDEPEND=""
DEPEND=""

DOCS="AUTHORS ChangeLog HACKING NEWS README"

xfce44_core_package
