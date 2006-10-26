# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.8-r4.ebuild,v 1.2 2006/10/17 06:41:51 uberlord Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls build static"

RDEPEND="!build? ( >=sys-libs/ncurses-5.2-r2 )
	!build? ( nls? ( virtual/libintl ) )"
DEPEND="${RDEPEND}
	!build? ( nls? ( sys-devel/gettext ) )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-freebsd.patch
	epatch "${FILESDIR}"/${P}-tempfile-owl.patch #114499
	epatch "${FILESDIR}"/${P}-bounds-check.patch #140902

	cd doc
	# Get the texinfo info page to have a proper name of texinfo.info
	sed -i 's:setfilename texinfo:setfilename texinfo.info:' texinfo.txi
	sed -i \
		-e 's:INFO_DEPS = texinfo:INFO_DEPS = texinfo.info:' \
		-e 's:texinfo\::texinfo.info\::' \
		Makefile.in
}

src_compile() {
	local myconf=
	if ! use nls || use build ; then
		myconf="--disable-nls"
	fi
	use static && append-ldflags -static

	econf ${myconf} || die

	# Cross-compile workaround #133429
	if tc-is-cross-compiler ; then
		emake -C tools || die "emake tools"
	fi

	# work around broken dependency's in info/Makefile.am #85540
	emake -C lib || die "emake lib"
	emake -C info makedoc || die "emake makedoc"
	emake -C info doc.c || die "emake doc.c"
	emake || die "emake"
}

src_install() {
	if use build ; then
		newbin util/ginstall-info install-info
		dobin makeinfo/makeinfo util/{texi2dvi,texindex}
	else
		make DESTDIR="${D}" install || die "install failed"
		dosbin ${FILESDIR}/mkinfodir
		# tetex installs this guy #76812
		has_version '<app-text/tetex-3' && rm -f "${ED}"/usr/bin/texi2pdf

		if [[ ! -f ${ED}/usr/share/info/texinfo.info ]] ; then
			die "Could not install texinfo.info!!!"
		fi

		dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
		newdoc info/README README.info
		newdoc makeinfo/README README.makeinfo
	fi
}
