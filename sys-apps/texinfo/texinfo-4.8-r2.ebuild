# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.8-r2.ebuild,v 1.1 2005/10/08 17:24:42 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ~ppc-macos ppc64 s390 sh sparc x86"
IUSE="nls build static"

RDEPEND="!build? ( >=sys-libs/ncurses-5.2-r2 )"
DEPEND="${RDEPEND}
	!build? ( nls? ( sys-devel/gettext ) )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-freebsd.patch
	epatch "${FILESDIR}"/${P}-tempfile.patch #106105

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
		make DESTDIR="${DEST}" install || die "install failed"
		dosbin ${FILESDIR}/mkinfodir
		# tetex installs this guy #76812
		has_version '<app-text/tetex-3' && rm -f "${D}"/usr/bin/texi2pdf

		if [[ ! -f ${D}/usr/share/info/texinfo.info ]] ; then
			die "Could not install texinfo.info!!!"
		fi

		dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
		newdoc info/README README.info
		newdoc makeinfo/README README.makeinfo
	fi
}
