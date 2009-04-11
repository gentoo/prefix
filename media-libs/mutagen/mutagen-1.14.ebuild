# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mutagen/mutagen-1.14.ebuild,v 1.7 2008/08/09 16:33:13 coldwind Exp $

inherit distutils eutils

DESCRIPTION="Mutagen is an audio metadata tag reader and writer implemented in pure Python."
HOMEPAGE="http://www.sacredchao.net/quodlibet/wiki/Development/Mutagen"
SRC_URI="http://www.sacredchao.net/~piman/software/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="test"

RDEPEND=">=virtual/python-2.4"
DEPEND="${RDEPEND}
	test? (	dev-python/eyeD3
		dev-python/pyvorbis
		media-libs/flac
		media-sound/vorbis-tools )"

DOCS="API-NOTES NEWS README TODO TUTORIAL"

src_test() {
	if ! built_with_use media-libs/flac ogg ; then
		ewarn "You need media-libs/flac to be built with use ogg in order to"
		ewarn "run the tests. Please re-install it with the ogg useflag enabled."
		ewarn "Skipping tests."
	else
		python setup.py test || die "src_test failed."
	fi
}
