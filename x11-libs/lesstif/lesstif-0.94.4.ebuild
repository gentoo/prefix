# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/lesstif/lesstif-0.94.4.ebuild,v 1.18 2007/01/04 18:55:05 flameeyes Exp $

EAPI="prefix"

inherit libtool flag-o-matic multilib

DESCRIPTION="An OSF/Motif(R) clone"
HOMEPAGE="http://www.lesstif.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2.1"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="static"

RDEPEND="virtual/libc
	x11-libs/libXp
	x11-libs/libXt
	>=x11-libs/motif-config-0.9"

DEPEND="dev-lang/perl
	${RDEPEND}
	x11-libs/libXaw
	x11-libs/libXft
	x11-proto/printproto
	>=sys-devel/libtool-1.5.10"

PROVIDE="virtual/motif"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/CAN-2005-0605.patch
}

src_compile() {
	econf \
	  $(use_enable static) \
	  --enable-production \
	  --enable-verbose=no \
	  --with-x || die "./configure failed"

	# fix linkage against already installed version
	perl -pi -e 's/^(hardcode_into_libs)=.*/$1=no/' libtool

	emake CFLAGS="${CFLAGS}" || die
}

src_install() {
	# fix linkage against already installed version
	for f in `find . -name \*.la -type f` ; do
		perl -pi -e 's/^(relink_command=.*)/# $1/' $f
	done

	make DESTDIR=${D} install || die "make install"


	einfo "Fixing binaries"
	dodir /usr/$(get_libdir)/lesstif-2.1
	for file in `ls ${ED}/usr/bin`
	do
		mv ${ED}/usr/bin/${file} ${ED}/usr/$(get_libdir)/lesstif-2.1/${file}
	done

	einfo "Fixing libraries"
	mv ${ED}/usr/lib/* ${ED}/usr/$(get_libdir)/lesstif-2.1/

	einfo "Fixing includes"
	dodir /usr/include/lesstif-2.1/
	mv ${ED}/usr/include/* ${ED}/usr/include/lesstif-2.1

	einfo "Fixing man pages"
	mans="1 3 5"
	for man in $mans; do
		dodir /usr/share/man/man${man}
		for file in `ls ${ED}/usr/share/man/man${man}`
		do
			file=${file/.${man}/}
			mv ${ED}/usr/share/man/man$man/${file}.${man} ${ED}/usr/share/man/man${man}/${file}-lesstif-2.1.${man}
		done
	done


	einfo "Fixing docs"
	dodir /usr/share/doc/
	mv ${ED}/usr/LessTif ${ED}/usr/share/doc/${P}
	rm -fR ${ED}/usr/$(get_libdir)/LessTif

	# cleanup
	rm -f ${ED}/usr/$(get_libdir)/lesstif-2.1/mxmkmf
	rm -fR ${ED}/usr/share/aclocal/
	rm -fR ${ED}/usr/$(get_libdir)/lesstif-2.1/LessTif/
	rm -fR ${ED}/usr/$(get_libdir)/lesstif-2.1/X11/
	rm -fR ${ED}/usr/$(get_libdir)/X11/
	rm -f ${ED}/usr/$(get_libdir)/lesstif-2.1/motif-config

	# profile stuff
	dodir /etc/env.d
	echo "LDPATH=/usr/lib/lesstif-2.1" > ${ED}/etc/env.d/15lesstif-2.1
	dodir /usr/$(get_libdir)/motif
	echo "PROFILE=lesstif-2.1" > ${ED}/usr/$(get_libdir)/motif/lesstif-2.1
}

pkg_postinst() {
	motif-config -s
}

pkg_postrm() {
	motif-config -s
}
