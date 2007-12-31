# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.3.0.ebuild,v 1.7 2007/12/30 16:54:31 betelgeuse Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.6"

inherit eutils libtool flag-o-matic multilib autotools

DESCRIPTION="Open Motif"
HOMEPAGE="http://www.motifzone.org/"
SRC_URI="ftp://ftp.ics.com/openmotif/2.3/${PV}/${P}.tar.gz
	doc? ( http://www.motifzone.net/files/documents/${P}-manual.pdf.tgz )"

LICENSE="MOTIF"
SLOT="2.3"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc xft jpeg png examples"

RDEPEND="
	x11-libs/libXmu
	x11-libs/libXaw
	x11-libs/libXp
	x11-proto/printproto
	xft? ( x11-libs/libXft )
	jpeg? ( media-libs/jpeg )
	png? ( media-libs/libpng )
	>=x11-libs/motif-config-0.9"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4
	x11-misc/xbitmaps"

PROVIDE="virtual/motif"

pkg_setup() {
	# multilib includes don't work right in this package...
	[ -n "${ABI}" ] && append-flags "-I${EPREFIX}/usr/include/gentoo-multilib/${ABI}"
}

src_compile() {
	local myconf

	# get around some LANG problems in make (#15119)
	unset LANG

	# bug #80421
	filter-flags -ftracer

	append-flags -fno-strict-aliasing

	use xft && myconf="${myconf} `use_enable xft`"
	use jpeg && myconf="${myconf} `use_enable jpeg`"
	use png && myconf="${myconf} `use_enable png`"

	econf --with-x \
	    ${myconf} || die "configuration failed"

	emake -j1 || die "make failed, if you have lesstif installed removed it, compile openmotif and recompile lesstif"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"

	# cleanups
	rm -fR ${ED}/usr/$(get_libdir)/X11
	rm -fR ${ED}/usr/$(get_libdir)/X11/bindings
	rm -fR ${ED}/usr/include/X11/

	list="/usr/share/man/man1/mwm.1 /usr/share/man/man4/mwmrc.4"
	for f in $list; do
		dosed 's:/usr/lib/X11/\(.*system\\&\.mwmrc\):${EPREFIX}/etc/X11/mwm/\1:g' "$f"
		dosed 's:/usr/lib/X11/app-defaults:${EPREFIX}/etc/X11/app-defaults:g' "$f"
	done

	einfo "Fixing binaries"
	dodir /usr/$(get_libdir)/openmotif-${SLOT}
	for file in `ls ${ED}/usr/bin`
	do
		mv ${ED}/usr/bin/${file} ${ED}/usr/$(get_libdir)/openmotif-${SLOT}/${file}
	done

	einfo "Fixing libraries"
	mv ${ED}/usr/$(get_libdir)/* ${ED}/usr/$(get_libdir)/openmotif-${SLOT}/

	einfo "Fixing includes"
	dodir /usr/include/openmotif-${SLOT}/
	mv ${ED}/usr/include/* ${ED}/usr/include/openmotif-${SLOT}

	einfo "Fixing man pages"
	mans="1 3 4 5"
	for man in $mans; do
		dodir /usr/share/man/man${man}
		for file in `ls ${ED}/usr/share/man/man${man}`
		do
			file=${file/.${man}/}
			mv ${ED}/usr/share/man/man$man/${file}.${man} ${ED}/usr/share/man/man${man}/${file}-openmotif-${SLOT}.${man}
		done
	done

	# install docs
	dodoc README RELEASE RELNOTES BUGREPORT TODO

	use doc && cp ${WORKDIR}/*.pdf ${ED}/usr/share/doc/${PF}

	if ( use examples )
	then
	    dodir /usr/share/doc/${PF}/demos
	    mv ${ED}/usr/share/Xm ${ED}/usr/share/doc/${PF}/demos
	else
	    rm -rf ${ED}/usr/share/Xm
	fi

	# profile stuff
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/openmotif-${SLOT}" > ${ED}/etc/env.d/15openmotif-${SLOT}
	dodir /usr/$(get_libdir)/motif
	echo "PROFILE=openmotif-${SLOT}" > ${ED}/usr/$(get_libdir)/motif/openmotif-${SLOT}
}

pkg_postinst() {
	"${EROOT}"/usr/bin/motif-config -s
}

pkg_postrm() {
	"${EROOT}"/usr/bin/motif-config -s
}
