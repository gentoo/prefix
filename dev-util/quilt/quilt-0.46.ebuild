# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/quilt/quilt-0.46.ebuild,v 1.2 2007/03/07 11:15:54 phreak Exp $

EAPI="prefix"

inherit bash-completion eutils

DESCRIPTION="quilt patch manager"
HOMEPAGE="http://savannah.nongnu.org/projects/quilt"
SRC_URI="http://savannah.nongnu.org/download/quilt/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="graphviz"

RDEPEND="sys-apps/ed
	dev-util/diffstat
	graphviz? ( media-gfx/graphviz )"

# The tests are somewhat broken while being run from within portage, work fine
# if you run them manually
RESTRICT="test"

pkg_setup() {
	echo
	elog "If you intend to use the folding functionality (graphical illustration of the patch stack)"
	elog "then you'll need to remerge this package with USE=graphviz."
	echo
	epause 5
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Add support for USE=graphviz
	use graphviz || epatch "${FILESDIR}/${P}-no-graphviz.patch"
}

src_compile() {
	local myconf=""
	[[ ${CHOST} == *"-darwin"* ]] && myconf="${myconf} --without-getopt"
	econf ${myconf}
	emake
}

src_install() {
	make BUILD_ROOT="${D}" install || die "make install failed"

	rm -rf "${ED}"/usr/share/doc/${P}
	dodoc AUTHORS TODO quilt.changes doc/README doc/README.MAIL \
		doc/quilt.pdf

	rm -rf "${ED}"/etc/bash_completion.d
	dobashcompletion bash_completion

	# Remove the compat symlinks
	rm -rf "${ED}"/usr/share/quilt/compat
}
