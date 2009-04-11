# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/rdiff-backup/rdiff-backup-1.2.1.ebuild,v 1.1 2008/09/03 16:21:18 wschlich Exp $

inherit distutils

DESCRIPTION="Remote incremental file backup utility; uses librsync's rdiff utility to create concise, versioned backups."
HOMEPAGE="http://www.nongnu.org/rdiff-backup/"
SRC_URI="http://savannah.nongnu.org/download/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="acl xattr"

DEPEND=">=net-libs/librsync-0.9.7
		!arm? ( xattr? ( dev-python/pyxattr )
				acl? ( dev-python/pylibacl ) )"
RDEPEND="${DEPEND}"

DOCS="examples.html"
