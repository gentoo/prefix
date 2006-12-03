# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-2.1.10.ebuild,v 1.6 2006/03/31 19:54:28 flameeyes Exp $

EAPI="prefix"

inherit eutils flag-o-matic gnuconfig libtool

SPV="`echo ${PV} | cut -d. -f1,2`"

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://sourceforge/freetype/${P/_/}.tar.bz2
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

	gnuconfig_update ${S}
	elibtoolize
	epunt_cxx

}

src_compile() {

	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=118021
	append-flags "-fno-strict-aliasing"

	use bindist || append-flags -DTT_CONFIG_OPTION_BYTECODE_INTERPRETER

	make setup CFG="--host=${CHOST} $(with_prefix) $(use_with zlib) --libdir=${EPREFIX}/usr/$(get_libdir)" unix || die

	emake || die

}

src_install() {

	make DESTDIR="${D}" install || die

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	cd ${WORKDIR}/${PN}-doc-${PV}
	use doc && dohtml -r docs/*

}
