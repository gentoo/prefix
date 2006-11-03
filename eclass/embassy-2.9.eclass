# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/embassy-2.9.eclass,v 1.8 2005/07/30 00:39:02 ribosome Exp $

# Author Olivier Fisette <ribosome@gentoo.org>

# This eclass is used to install EMBASSY programs (EMBOSS add-ons).

# The inheriting ebuild should provide a "DESCRIPTION", "KEYWORDS" and, if
# necessary, add "(R|P)DEPEND"encies. Additionnaly, the inheriting ebuild's
# name must begin by "embassy-".

inherit eutils multilib

# EMBOSS version needed for the EMBASSY packages
EBOV="2.9.0"
# The EMBASSY package name, retrieved from the inheriting ebuild's name
EN=${PN:8}
# The full name and version of the EMBASSY package (excluding the Gentoo
# revision number)
EF="$(echo ${EN} | tr "[:lower:]" "[:upper:]")-${PV}"

DESCRIPTION="Based on the $ECLASS eclass"
HOMEPAGE="http://emboss.sourceforge.net/"
LICENSE="GPL-2"
SRC_URI="ftp://ftp.uk.embnet.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	ftp://ftp.uk.embnet.org/pub/EMBOSS/${EF}.tar.gz"

SLOT="0"
IUSE="X png"

DEPEND="=sci-biology/emboss-${EBOV}
	!=sci-biology/emboss-2.10*
	X? ( virtual/x11 )
	png? ( sys-libs/zlib
		media-libs/libpng
		>=media-libs/gd-1.8
	)"

S=${WORKDIR}/EMBOSS-${EBOV}/embassy/${EF}

embassy-2.9_src_unpack() {
	unpack ${A}
	mkdir EMBOSS-${EBOV}/embassy
	mv ${EF} EMBOSS-${EBOV}/embassy/
	cp "${EROOT}"/usr/$(get_libdir)/libplplot.la EMBOSS-${EBOV}/plplot/
	cp "${EROOT}"/usr/$(get_libdir)/libajax.la EMBOSS-${EBOV}/ajax/
	cp "${EROOT}"/usr/$(get_libdir)/libajaxg.la EMBOSS-${EBOV}/ajax/
	cp "${EROOT}"/usr/$(get_libdir)/libnucleus.la EMBOSS-${EBOV}/nucleus/
}

embassy-2.9_src_compile() {
	local EXTRA_CONF
	! use X && EXTRA_CONF="${EXTRA_CONF} --without-x"
	! use png && EXTRA_CONF="${EXTRA_CONF} --without-pngdriver"
	./configure --host=${CHOST} \
		--mandir="${EPREFIX}"/usr/share/man \
		--infodir="${EPREFIX}"/usr/share/info \
		--datadir="${EPREFIX}"/usr/share \
		--sysconfdir="${EPREFIX}"/etc \
		--localstatedir="${EPREFIX}"/var/lib \
		${EXTRA_CONF} || die
	emake || die "Before reporting this error as a bug, please make sure you compiled
    EMBOSS and the EMBASSY packages with the same \"USE\" flags. Failure to
    do so may prevent the compilation of some EMBASSY packages, or cause
    runtime problems with some EMBASSY programs. For example, if you
    compile EMBOSS with \"png\" support and then try to build DOMAINATRIX
    without \"png\" support, compilation will fail when linking the binaries."
}

embassy-2.9_src_install() {
	einstall || die
	dodoc AUTHORS ChangeLog NEWS README
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
