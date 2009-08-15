# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libusb/libusb-0.ebuild,v 1.3 2009/05/16 06:52:15 robbat2 Exp $

EAPI=2

DESCRIPTION="Virtual for libusb"
HOMEPAGE="http://libusb.sourceforge.net/"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND="|| ( >=dev-libs/libusb-0.1.12-r1:0 dev-libs/libusb-compat )"
