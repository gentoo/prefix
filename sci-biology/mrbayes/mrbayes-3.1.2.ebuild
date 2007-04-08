# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/mrbayes/mrbayes-3.1.2.ebuild,v 1.5 2007/03/25 01:57:56 kugelfang Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Bayesian Inference of Phylogeny"
LICENSE="GPL-2"
HOMEPAGE="http://mrbayes.csit.fsu.edu/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

SLOT="0"
IUSE="mpi readline"
KEYWORDS="~ppc-macos x86"

DEPEND="mpi? ( virtual/mpi )
	readline? ( sys-libs/readline )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -e "s:OPTFLAGS ?= -O3:CFLAGS = ${CFLAGS}:" \
		-e "s:CC = gcc:CC = $(tc-getCC):" \
		-i Makefile || die "Patching CC/CFLAGS."
	if use mpi; then
		sed -e "s:MPI ?= no:MPI=yes:" -i Makefile || die "Patching MPI support."
	fi
	if ! use readline; then
		sed -e "s:USEREADLINE ?= yes:USEREADLINE=no:" \
			-i Makefile || die "Patching readline support."
	else
		# Only needed for OSX with an old (4.x) version of
		# libreadline, but it doesn't hurt for other distributions.
		epatch "${FILESDIR}"/mb_readline_312.patch
	fi
}

src_install() {
	dobin mb || die "Installation failed."
}
