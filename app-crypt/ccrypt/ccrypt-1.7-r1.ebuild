# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/ccrypt/ccrypt-1.7-r1.ebuild,v 1.5 2008/01/11 20:38:20 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Encryption and decryption"
HOMEPAGE="http://ccrypt.sourceforge.net"
SRC_URI="http://ccrypt.sourceforge.net/download/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# bug#181397
	# Upstream
	# http://sourceforge.net/tracker/index.php?func=detail&aid=1734098&group_id=40913&atid=429291
	epatch "${FILESDIR}/${P}-emacs.patch"
}

src_install () {
	emake \
		DESTDIR="${D}" \
		htmldir="${EPREFIX}"/usr/share/doc/${PF} \
		install || die
	dodoc AUTHORS ChangeLog NEWS README
}
