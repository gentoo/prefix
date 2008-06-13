# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/inputproto/inputproto-1.4.3-r1.ebuild,v 1.1 2008/03/12 03:50:27 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Input protocol headers"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}"

PATCHES="
	${FILESDIR}/0001-C-sucks-define-XEventClass-in-terms-of-unsigned-int.patch
	${FILESDIR}/0002-Typo-fix.patch
	"
