# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy/embassy-5.0.0.ebuild,v 1.1 2007/07/18 02:43:05 ribosome Exp $

EAPI="prefix"

DESCRIPTION="A meta-package for installing all EMBASSY packages (EMBOSS add-ons)"
HOMEPAGE="http://www.emboss.org/"
SRC_URI=""
LICENSE="GPL-2 freedist"

SLOT="0"
KEYWORDS="~ppc-macos ~x86"
IUSE=""

RDEPEND="!<sci-biology/emboss-5.0.0
	!sci-biology/embassy-memenew
	!sci-biology/embassy-phylipnew
	~sci-biology/emboss-5.0.0
	=sci-biology/embassy-domainatrix-0.1.0-r2
	=sci-biology/embassy-domalign-0.1.0-r2
	=sci-biology/embassy-domsearch-0.1.0-r2
	=sci-biology/embassy-emnu-1.05-r4
	=sci-biology/embassy-esim4-1.0.0-r4
	=sci-biology/embassy-hmmer-2.3.2-r1
	=sci-biology/embassy-meme-0.1.0
	=sci-biology/embassy-mse-1.0.0-r5
	=sci-biology/embassy-phylip-3.6b
	=sci-biology/embassy-signature-0.1.0-r2
	=sci-biology/embassy-structure-0.1.0-r2
	=sci-biology/embassy-topo-1.0.0-r4
	=sci-biology/embassy-vienna-1.6"
