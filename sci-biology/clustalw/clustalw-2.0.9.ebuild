# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/clustalw/clustalw-2.0.9.ebuild,v 1.2 2008/09/09 13:29:27 markusle Exp $

DESCRIPTION="General purpose multiple alignment program for DNA and proteins"
HOMEPAGE="http://www.ebi.ac.uk/tools/clustalw2/"
SRC_URI="ftp://ftp.ebi.ac.uk/pub/software/clustalw2/${PV}/${P}-src.tar.gz"

LICENSE="clustalw"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

src_install() {
	einstall || die "Installation failed."
}
