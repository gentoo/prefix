# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-2.1.10-r3.ebuild,v 1.1 2007/04/04 14:23:26 foser Exp $

EAPI="prefix"

inherit eutils flag-o-matic libtool

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://sourceforge/freetype/${P/_/}.tar.bz2
	mirror://gentoo/freetype-2.1.10-security_batch-r1.patch.bz2
	doc? ( mirror://sourceforge/${PN}/${PN}-doc-${PV}.tar.bz2 )"

LICENSE="FTL GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="zlib bindist doc"

# The RDEPEND below makes sure that if there is a version of moz/ff/tb
# installed, then it will have the freetype-2.1.8+ binary compatibility patch.
# Otherwise updating freetype will cause moz/ff/tb crashes.  #59849
# 20 Nov 2004 agriffis
DEPEND="zlib? ( sys-libs/zlib )"

RDEPEND="${DEPEND}
	!<www-client/mozilla-1.7.3-r3
	!<www-client/mozilla-firefox-1.0-r3
	!<mail-client/mozilla-thunderbird-0.9-r3
	!<media-libs/libwmf-0.2.8.2"

src_unpack() {

	unpack ${A}

	# fix internal header cast which gets used by pango (bad)
	epatch ${FILESDIR}/${P}-internal_header.patch
	# fix bunch of overflows etc. (#124828)
	epatch ${WORKDIR}/${P}-security_batch-r1.patch
	# revert pointer
	epatch ${FILESDIR}/${P}-revert_pointer.patch
	# fix artificial bold bug (#127872)
	cd ${S}/src/base
	epatch ${FILESDIR}/${P}-fix_synth.patch
	# fix CVE-2007-1351 (#172577)
	cd ${S}
	epatch "${FILESDIR}/${PN}-2.3.2-bdflib.patch"

	elibtoolize
	epunt_cxx

}

src_compile() {

	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=118021
	append-flags "-fno-strict-aliasing"

	use bindist || append-flags -DTT_CONFIG_OPTION_BYTECODE_INTERPRETER

	# Fix missing symbols in fontconfig in some circumstances
	append-flags -DFT_CONFIG_OPTION_OLD_INTERNALS

	make setup CFG="--host=${CHOST} --prefix=${EPREFIX}/usr $(use_with zlib) --libdir=${EPREFIX}/usr/$(get_libdir)" unix || die

	emake || die "make failed"

	if use doc ; then
		emake refdoc || die "refdoc failed"
	fi

}

src_install() {

	make DESTDIR="${D}" install || die

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	cd ${WORKDIR}/${PN}-doc-${PV}
	use doc && dohtml -r docs/*

}
